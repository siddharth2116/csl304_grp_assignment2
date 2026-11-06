;; Problem 2: Mars Rover Sample Collection - Domain
;; Uses only :strips and :typing (no numeric fluents, no negative preconditions)

(define (domain mars-rover)
  (:requirements :strips :typing)

  ;; ---------------- Types ----------------
  (:types
    rover location rock bay drill)

  ;; ---------------- Predicates ----------------
  (:predicates
    (rover-at ?rv - rover ?l - location)        ; rover is at location l
    (connected ?from - location ?to - location) ; rover can drive from -> to
    (rock-at ?r - rock ?l - location)           ; rock lies at location l
    (soft ?r - rock)                            ; rock can be collected directly
    (hard ?r - rock)                            ; rock needs the drill
    (drill-at ?d - drill ?l - location)         ; drill lies at location l
    (has-drill ?rv - rover)                     ; rover is carrying the drill
    (bay-of ?b - bay ?rv - rover)               ; bay b belongs to rover rv
    (empty ?b - bay)                            ; bay b holds no rock
    (in-bay ?r - rock ?b - bay))                ; rock r is stored in bay b

  ;; ---------------- Actions ----------------

  ;; Move between connected locations (one-way route is modelled by
  ;; giving only one direction of the connected fact)
  (:action move
    :parameters (?rv - rover ?from - location ?to - location)
    :precondition (and (rover-at ?rv ?from) (connected ?from ?to))
    :effect (and (rover-at ?rv ?to) (not (rover-at ?rv ?from))))

  ;; Pick up the drill; the rover keeps it for the rest of the mission
  (:action pick-drill
    :parameters (?rv - rover ?d - drill ?l - location)
    :precondition (and (rover-at ?rv ?l) (drill-at ?d ?l))
    :effect (and (has-drill ?rv) (not (drill-at ?d ?l))))

  ;; Collect a soft rock into an empty bay
  (:action collect-soft
    :parameters (?rv - rover ?r - rock ?b - bay ?l - location)
    :precondition (and (rover-at ?rv ?l) (rock-at ?r ?l) (soft ?r)
                       (bay-of ?b ?rv) (empty ?b))
    :effect (and (in-bay ?r ?b) (not (rock-at ?r ?l)) (not (empty ?b))))

  ;; Collect a hard rock into an empty bay (drill required)
  (:action collect-hard
    :parameters (?rv - rover ?r - rock ?b - bay ?l - location)
    :precondition (and (rover-at ?rv ?l) (rock-at ?r ?l) (hard ?r)
                       (has-drill ?rv) (bay-of ?b ?rv) (empty ?b))
    :effect (and (in-bay ?r ?b) (not (rock-at ?r ?l)) (not (empty ?b))))

  ;; Deposit a rock from a bay at the rover's current location
  (:action deposit
    :parameters (?rv - rover ?r - rock ?b - bay ?l - location)
    :precondition (and (rover-at ?rv ?l) (in-bay ?r ?b) (bay-of ?b ?rv))
    :effect (and (rock-at ?r ?l) (empty ?b) (not (in-bay ?r ?b))))
)
