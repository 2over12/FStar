module FStar.SizeT

open FStar.Mul

module U16 = FStar.UInt16
module U64 = FStar.UInt64

val t : eqtype

val fits (x: nat) : Tot prop

val v (x: t) : Ghost nat
  (requires True)
  (ensures (fun y -> fits y))

val size_v_inj (x1 x2: t) : Lemma
  (v x1 == v x2 ==> x1 == x2)
  [SMTPat (v x1); SMTPat (v x2)]

/// According to the C standard, "the bit width of t is not less than 16 since c99"
/// (https://en.cppreference.com/w/c/types/t)
/// We therefore offer two functions to create a t value.
/// Any value that fits in a uint_16 can be cast directly to t
/// Any value that might not fit in a uint_16 needs to be checked,
/// we will add a static_assert during extraction
val mk (x: U16.t) : Pure t
  (requires True)
  (ensures (fun y -> v y == U16.v x))

val mk_checked (x: U64.t) : Pure t
  (requires True)
  (ensures (fun y -> v y == U64.v x))

val int_to_t (x: nat) : Ghost t
  (requires (fits x))
  (ensures (fun y -> v y == x))

val fits_le (x y: nat) : Lemma
  (requires (x <= y /\ fits y))
  (ensures (fits x))
  [SMTPat (fits x); SMTPat (fits y)]

val add (x y: t) : Pure t
  (requires (fits (v x + v y)))
  (ensures (fun z -> v z == v x + v y))

val sub (x y: t) : Pure t
  (requires (v x >= v y))
  (ensures (fun z -> v z == v x - v y))

val mul (x y: t) : Pure t
  (requires (fits (v x * v y)))
  (ensures (fun z -> v z == v x * v y))

val le (x y: t) : Pure bool
  (requires True)
  (ensures (fun z -> z == (v x <= v y)))

let zero : (zero_size: t { v zero_size == 0 }) = mk 0us

let one : (zero_size: t { v zero_size == 1 }) = mk 1us
