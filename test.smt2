; Test file for the SMT-LIB extension: exercises most of the SMT-LIB 2.6
; syntax supported by Dolmen v0.10 (commands, datatypes, match, recursive
; functions, and the Core, Ints, Reals, Arrays, BitVectors, FloatingPoint and
; Strings theories). It should type check without any error.

(set-info :smt-lib-version 2.6)
(set-info :source |Generated to test syntax highlighting and diagnostics.|)
(set-info :status unknown)
(set-option :produce-models true)
(set-option :produce-unsat-cores true)
(set-option :produce-assignments true)
(set-logic ALL)

; ---------------------------------------------------------------------------
; Sorts
; ---------------------------------------------------------------------------

(declare-sort Elem 0)
(declare-sort Pair 2)
(define-sort Set (T) (Array T Bool))
(define-sort Word () (_ BitVec 32))
(define-sort Matrix (T) (Array Int (Array Int T)))

; ---------------------------------------------------------------------------
; Datatypes
; ---------------------------------------------------------------------------

(declare-datatype Color ((red) (green) (blue)))

(declare-datatype Option (par (T) ((none) (some (value T)))))

(declare-datatype Point ((mk-point (px Real) (py Real))))

(declare-datatypes ((List 1) (Tree 1)) (
  (par (T) ((nil) (cons (head T) (tail (List T)))))
  (par (T) ((leaf) (node (label T) (children (List (Tree T))))))))

(declare-datatypes ((Expr 0) (Stmt 0)) (
  ((num (n Int))
   (var (name String))
   (add (lhs Expr) (rhs Expr))
   (mul (lhs2 Expr) (rhs2 Expr))
   (neg (arg Expr)))
  ((assign (target String) (expr Expr))
   (seq (first Stmt) (second Stmt))
   (skip))))

; ---------------------------------------------------------------------------
; Constants and functions
; ---------------------------------------------------------------------------

(declare-const x Int)
(declare-const y Int)
(declare-const z Real)
(declare-const b Bool)
(declare-const c Color)
(declare-const e Elem)
(declare-const p Point)
(declare-const ints (List Int))
(declare-const tree (Tree Int))
(declare-const program Stmt)
(declare-const |a quoted name| Int)
(declare-const |x+y*2| Real)
(declare-fun f (Int Int) Int)
(declare-fun g (Elem) Elem)
(declare-fun member (Elem (Set Elem)) Bool)
(declare-fun swap ((Pair Int Bool)) (Pair Bool Int))

(define-fun max2 ((i Int) (j Int)) Int (ite (>= i j) i j))
(define-fun abs-diff ((i Real) (j Real)) Real (ite (> i j) (- i j) (- j i)))
(define-fun is-primary ((col Color)) Bool (or (= col red) (= col green) (= col blue)))
(define-fun origin () Point (mk-point 0.0 0.0))

(define-fun-rec length ((l (List Int))) Int
  (match l (
    (nil 0)
    ((cons h t) (+ 1 (length t))))))

(define-fun-rec eval ((ex Expr)) Int
  (match ex (
    ((num k) k)
    ((var s) 0)
    ((add l r) (+ (eval l) (eval r)))
    ((mul l r) (* (eval l) (eval r)))
    ((neg a) (- (eval a))))))

(define-funs-rec (
  (is-even ((k Int)) Bool)
  (is-odd ((k Int)) Bool))
  ((ite (= k 0) true (is-odd (- k 1)))
   (ite (= k 0) false (is-even (- k 1)))))

; ---------------------------------------------------------------------------
; Core and arithmetic
; ---------------------------------------------------------------------------

(assert (! (and (> x 0) (< y 100) (distinct x y)) :named bounds))
(assert (=> b (xor (<= x y) (not (= x (f x y))))))
(assert (let ((s (+ x y)) (d (- x y))) (and (>= s d) (= (max2 s d) s))))
(assert (= (div x 3) (mod y 7)))
(assert (= (abs (- x)) x))
(assert ((_ divisible 4) (* 2 x)))
(assert (= z (/ (to_real x) 3.5)))
(assert (is_int (to_real (to_int z))))
(assert (>= (abs-diff z 1.25) 0.0))
(assert (= |a quoted name| (+ x 42)))

; ---------------------------------------------------------------------------
; Quantifiers
; ---------------------------------------------------------------------------

(assert (forall ((i Int) (j Int))
  (! (= (f i j) (f j i)) :pattern ((f i j)))))
(assert (exists ((k Int)) (and (> k x) (is-even k))))
(declare-const empty (Set Elem))
(assert (forall ((u Elem)) (not (select empty u))))
(assert (forall ((u Elem)) (=> (member u empty) (= (g u) u))))

; ---------------------------------------------------------------------------
; Datatypes and match
; ---------------------------------------------------------------------------

(assert (not (= c red)))
(assert ((_ is cons) ints))
(assert (= (head ints) x))
(assert (= (length ints) 3))
(assert (= tree (node 1 (cons (as leaf (Tree Int)) (cons (node 2 (as nil (List (Tree Int)))) (as nil (List (Tree Int))))))))
(assert (= (px p) (py origin)))
(assert (match c ((red false) (green true) (blue b))))
(assert (= (eval (add (num 2) (mul (num 3) (neg (var "x"))))) (- 7)))
(assert (= program (seq (assign "x" (num 1)) (seq (assign "y" (var "x")) skip))))
(assert (= (as none (Option Int)) (as none (Option Int))))
(assert ((_ is some) (some 5)))

; ---------------------------------------------------------------------------
; Arrays
; ---------------------------------------------------------------------------

(declare-const arr (Array Int Int))
(declare-const grid (Matrix Real))
(assert (= (select (store arr 0 x) 0) x))
(assert (= (select (select grid 1) 2) z))
(assert (= arr (store (store arr 1 y) 1 (select arr 1))))

; ---------------------------------------------------------------------------
; Bit-vectors
; ---------------------------------------------------------------------------

(declare-const w Word)
(declare-const v (_ BitVec 8))
(assert (= (bvadd v #x0F) (bvmul v #b00000011)))
(assert (bvult (bvand v (bvnot #x00)) (bvor v #xF0)))
(assert (= ((_ extract 7 0) w) (bvxor v (bvneg v))))
(assert (= (concat (concat v v) (concat v v)) (bvshl w (_ bv8 32))))
(assert (= ((_ zero_extend 24) v) (bvlshr w ((_ sign_extend 24) #x01))))
(assert (= ((_ repeat 4) v) ((_ rotate_left 3) ((_ rotate_right 5) w))))
(assert (bvsle (bvsdiv w (_ bv2 32)) (bvsrem w (bvudiv w (bvurem w #x00000007)))))
(assert (= (bvcomp v v) #b1))
(assert (bvsge (bvashr w (_ bv1 32)) (bvsmod w (_ bv3 32))))
(assert (= (bvnand v v) (bvnor (bvxnor v v) (bvsub v #x01))))

; ---------------------------------------------------------------------------
; Floating point
; ---------------------------------------------------------------------------

(declare-const fx Float32)
(declare-const fy Float64)
(declare-const fz (_ FloatingPoint 5 11))
(declare-const rm RoundingMode)
(assert (not (fp.isNaN fx)))
(assert (fp.lt (fp.add RNE fx (fp #b0 #x7F #b00000000000000000000000)) ((_ to_fp 8 24) RTZ 3.0)))
(assert (fp.eq (fp.mul rm fy fy) (fp.fma roundNearestTiesToEven fy fy ((_ to_fp 11 53) RNA 0.5))))
(assert (fp.isNormal (fp.sqrt roundTowardPositive fy)))
(assert (fp.geq (fp.abs fz) (fp.neg (_ +zero 5 11))))
(assert (not (fp.isInfinite (fp.div roundTowardNegative fx (_ -zero 8 24)))))
(assert (= ((_ fp.to_sbv 16) RTZ fz) ((_ fp.to_ubv 16) roundTowardZero fz)))
(assert (fp.leq (fp.min fx fx) (fp.max fx ((_ to_fp_unsigned 8 24) RTP #x0000FFFF))))
(assert (= (fp.to_real (fp.roundToIntegral RNE fx)) z))
(assert (or (fp.isZero fz) (fp.isSubnormal fz) (fp.isPositive fz) (fp.isNegative fz)))
(assert (fp.gt (_ +oo 11 53) (fp.rem fy (_ -oo 11 53))))
(assert (not (= fz (_ NaN 5 11))))

; ---------------------------------------------------------------------------
; Strings and regular expressions
; ---------------------------------------------------------------------------

(declare-const s String)
(declare-const t String)
(declare-const re RegLan)
(assert (= (str.++ s " and " t) "left and right"))
(assert (= (str.len "say ""hi""") 10))
(assert (str.prefixof "left" s))
(assert (str.suffixof "right" t))
(assert (str.contains (str.substr s 0 3) (str.at s 1)))
(assert (= (str.indexof s "e" 0) 1))
(assert (= (str.replace_all (str.replace s "l" "L") "e" "E") "LEft"))
(assert (str.< "abc" (str.from_int (str.to_int "42"))))
(assert (str.<= s t))
(assert (str.is_digit (str.from_code 55)))
(assert (= re (re.union (str.to_re "a") (re.++ (re.* (re.range "0" "9")) (re.opt (str.to_re "!"))))))
(assert (str.in_re s (re.inter re.all (re.comp re.none))))
(assert (str.in_re t (re.diff (re.+ re.allchar) ((_ re.loop 1 3) (str.to_re "x")))))
(assert (str.in_re "aaa" ((_ re.^ 3) (str.to_re "a"))))
(assert (= (str.replace_re s re "") (str.replace_re_all t re "")))
(assert (= "" ""))

; ---------------------------------------------------------------------------
; Commands
; ---------------------------------------------------------------------------

(push 1)
(assert (< x 0))
(check-sat)
(get-unsat-core)
(pop 1)

(check-sat-assuming (bounds (not b)))
(get-unsat-assumptions)
(check-sat)
(get-model)
(get-value (x y (f x y) (length ints)))
(get-assignment)
(get-assertions)
(get-info :reason-unknown)
(get-option :produce-models)
(echo "done with ""test.smt2""")
(reset-assertions)
(reset)
(exit)
