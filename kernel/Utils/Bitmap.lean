prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Utils.Memory

namespace Kernel.Utils.Bitmap

open Kernel.Utils.Memory (load64 load8)
open Kernel.Utils.Memory.KernelM (run store64 store8)

@[extern "bit_ctz64"]
opaque ctz64 : UInt64 -> UInt64

def byteAddr (addr index : UInt64) : UInt64 := addr + (index >>> 3)

def bitMask (index : UInt64) : UInt8 := (1 <<< (index &&& 7)).toUInt8

partial def clearBytesFrom (current token rem : UInt64) : UInt64 :=
  if rem == 0 then
    token
  else if rem >= 8 && current &&& 7 == 0 then
    let token := run (store64 current 0) token
    clearBytesFrom (current + 8) token (rem - 8)
  else
    let token := run (store8 current 0) token
    clearBytesFrom (current + 1) token (rem - 1)

def clearBytes (addr size index token : UInt64) : UInt64 :=
  let rem := if size > index then size - index else 0
  clearBytesFrom (addr + index) token rem

def get (addr : UInt64) (index : UInt64) : Bool :=
  let byte := load8 (byteAddr addr index)
  byte &&& bitMask index != 0

def set (addr : UInt64) (index : UInt64) (value : Bool) (token : UInt64) : UInt64 :=
  let addr := byteAddr addr index
  let mask := bitMask index
  let old := load8 addr
  let new := if value then old ||| mask else old &&& ~~~mask
  run (store8 addr new) token

partial def setRangeFrom (addr index rem : UInt64) (value : Bool) (token : UInt64) : UInt64 :=
  if rem == 0 then
    token
  else if rem >= 64 && index &&& 63 == 0 then
    let word := if value then ~~~0 else 0
    let token := run (store64 (byteAddr addr index) word) token
    setRangeFrom addr (index + 64) (rem - 64) value token
  else
    let token := set addr index value token
    setRangeFrom addr (index + 1) (rem - 1) value token

def setRange (addr len start endIndex : UInt64) (value : Bool) (token : UInt64) : UInt64 :=
  let endIndex := if endIndex < len then endIndex else len
  if start >= endIndex then
    token
  else
    setRangeFrom addr start (endIndex - start) value token

partial def findFrom
    (addr len length : UInt64) (value : Bool)
    (bitIndex rem count start word wordRem : UInt64) : UInt64 :=
  if rem == 0 && wordRem == 0 then
    len
  else if wordRem == 0 then
    let w := load64 (byteAddr addr bitIndex)
    let matched := if value then w else ~~~w
    let bits := if rem < 64 then rem else 64
    let mask := if bits < 64 then (1 <<< bits) - 1 else ~~~0
    let matched := matched &&& mask
    if matched == 0 then
      findFrom addr len length value (bitIndex + bits) (rem - bits) 0 start 0 0
    else if matched == ~~~0 then
      let start := if count == 0 then bitIndex else start
      let count := count + bits
      if count >= length then start
      else
        findFrom addr len length value (bitIndex + bits) (rem - bits) count start 0 0
    else
      findFrom addr len length value bitIndex rem count start matched bits
  else if word == 0 then
    findFrom addr len length value (bitIndex + wordRem) (rem - wordRem) 0 start 0 0
  else
    let zeros := ctz64 word
    let count := if zeros == 0 then count else 0
    let start := if count == 0 then bitIndex + zeros else start
    let word := word >>> zeros
    let ones := ctz64 (~~~word)
    let count := count + ones
    if count >= length then
      start
    else
      let step := zeros + ones
      findFrom
        addr len length value (bitIndex + step) (rem - step)
        count start (word >>> ones) (wordRem - step)

def findRange (addr len length : UInt64) (value : Bool) : UInt64 :=
  if length == 0 || len == 0 then 0
  else findFrom addr len length value 0 len 0 0 0 0

end Kernel.Utils.Bitmap
