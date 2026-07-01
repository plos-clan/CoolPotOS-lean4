prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Utils.Memory

namespace Kernel.Utils.Bitmap

open Kernel.Utils.Memory (load8)
open Kernel.Utils.Memory.KernelM (run store8)

def byteAddr (addr index : UInt64) : UInt64 := addr + (index >>> 3)

def bitMask (index : UInt64) : UInt8 := (1 <<< (index &&& 7)).toUInt8

def fullByte (value : Bool) : UInt8 := if value then 0xff else 0

partial def clearBytes (addr size index token : UInt64) : UInt64 :=
  if index == size then
    token
  else
    let token := run (store8 (addr + index) 0) token
    clearBytes addr size (index + 1) token

def get (addr : UInt64) (index : UInt64) : Bool :=
  let byte := load8 (byteAddr addr index)
  byte &&& bitMask index != 0

def set (addr : UInt64) (index : UInt64) (value : Bool) (token : UInt64) : UInt64 :=
  let addr := byteAddr addr index
  let mask := bitMask index
  let old := load8 addr
  let new := if value then old ||| mask else old &&& ~~~mask
  run (store8 addr new) token

partial def setRangeBits
    (addr len index endIndex : UInt64) (value : Bool) (token : UInt64) : UInt64 :=
  if index >= endIndex || index >= len then
    token
  else if
      index % 8 == 0 &&
      index + 8 <= endIndex &&
      index + 8 <= len then
    let token := run (store8 (byteAddr addr index) (fullByte value)) token
    setRangeBits addr len (index + 8) endIndex value token
  else
    let token := set addr index value token
    setRangeBits addr len (index + 1) endIndex value token

def setRange (addr len start endIndex : UInt64) (value : Bool) (token : UInt64) : UInt64 :=
  if start >= endIndex || start >= len then
    token
  else
    setRangeBits addr len start endIndex value token

partial def findRangeFrom
    (addr len index count start length : UInt64) (value : Bool) : UInt64 :=
  if index >= len then
    len
  else
    let canFastForward :=
      index % 8 == 0 && index + 8 <= len
    let byte := if canFastForward then load8 (byteAddr addr index) else 0
    if canFastForward && byte == fullByte (!value) then
      findRangeFrom
        addr len (index + 8) 0 0 length value
    else if canFastForward && byte == fullByte value then
      let start := if count == 0 then index else start
      let count := count + 8
      if count >= length then
        start
      else
        findRangeFrom addr len (index + 8) count start length value
    else
      let ok := get addr index == value
      let start := if ok && count == 0 then index else start
      let count := if ok then count + 1 else 0
      if count == length then
        start
      else
        findRangeFrom addr len (index + 1) count start length value

def findRange (addr len length : UInt64) (value : Bool) : UInt64 :=
  findRangeFrom addr len 0 0 0 length value

end Kernel.Utils.Bitmap
