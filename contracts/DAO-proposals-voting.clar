(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u101))
(define-constant ERR-VOTING-ENDED (err u102))
(define-constant ERR-VOTING-ACTIVE (err u103))
(define-constant ERR-ALREADY-VOTED (err u104))
(define-constant ERR-NOT-MEMBER (err u105))
(define-constant ERR-INVALID-VOTING-PERIOD (err u106))
(define-constant ERR-PROPOSAL-EXECUTED (err u107))
(define-constant ERR-QUORUM-NOT-MET (err u108))
(define-constant ERR-INVALID-QUORUM (err u109))

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-VOTING-PERIOD u144)
(define-constant MAX-VOTING-PERIOD u4320)

(define-data-var proposal-counter uint u0)
(define-data-var member-counter uint u0)
(define-data-var quorum-percentage uint u50)
(define-data-var total-voting-power uint u0)

(define-map members principal bool)
(define-map member-voting-power principal uint)

(define-map proposals
  uint
  {
    id: uint,
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    start-block: uint,
    end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    executed: bool,
    passed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool, voting-power: uint }
)

(define-public (add-member (member principal) (voting-power uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> voting-power u0) ERR-NOT-AUTHORIZED)
    (map-set members member true)
    (map-set member-voting-power member voting-power)
    (var-set member-counter (+ (var-get member-counter) u1))
    (var-set total-voting-power (+ (var-get total-voting-power) voting-power))
    (ok true)
  )
)

(define-public (remove-member (member principal))
  (let
    (
      (member-power (default-to u0 (map-get? member-voting-power member)))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-delete members member)
    (map-delete member-voting-power member)
    (var-set member-counter (- (var-get member-counter) u1))
    (var-set total-voting-power (- (var-get total-voting-power) member-power))
    (ok true)
  )
)

(define-public (submit-proposal 
  (title (string-ascii 100)) 
  (description (string-ascii 500)) 
  (voting-period uint))
  (let
    (
      (proposal-id (+ (var-get proposal-counter) u1))
      (start-block stacks-block-height)
      (end-block (+ stacks-block-height voting-period))
    )
    (asserts! (is-member tx-sender) ERR-NOT-MEMBER)
    (asserts! (and (>= voting-period MIN-VOTING-PERIOD) (<= voting-period MAX-VOTING-PERIOD)) ERR-INVALID-VOTING-PERIOD)
    
    (map-set proposals proposal-id
      {
        id: proposal-id,
        proposer: tx-sender,
        title: title,
        description: description,
        start-block: start-block,
        end-block: end-block,
        yes-votes: u0,
        no-votes: u0,
        executed: false,
        passed: false
      }
    )
    (var-set proposal-counter proposal-id)
    (ok proposal-id)
  )
)

(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let
    (
      (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
      (voter-power (unwrap! (map-get? member-voting-power tx-sender) ERR-NOT-MEMBER))
      (vote-key { proposal-id: proposal-id, voter: tx-sender })
    )
    (asserts! (is-member tx-sender) ERR-NOT-MEMBER)
    (asserts! (<= stacks-block-height (get end-block proposal)) ERR-VOTING-ENDED)
    (asserts! (is-none (map-get? votes vote-key)) ERR-ALREADY-VOTED)
    
    (map-set votes vote-key { vote: vote, voting-power: voter-power })
    
    (if vote
      (map-set proposals proposal-id
        (merge proposal { yes-votes: (+ (get yes-votes proposal) voter-power) })
      )
      (map-set proposals proposal-id
        (merge proposal { no-votes: (+ (get no-votes proposal) voter-power) })
      )
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
      (total-votes (+ (get yes-votes proposal) (get no-votes proposal)))
      (required-quorum (/ (* (var-get total-voting-power) (var-get quorum-percentage)) u100))
    )
    (asserts! (> stacks-block-height (get end-block proposal)) ERR-VOTING-ACTIVE)
    (asserts! (not (get executed proposal)) ERR-PROPOSAL-EXECUTED)
    (asserts! (>= total-votes required-quorum) ERR-QUORUM-NOT-MET)
    
    (let
      (
        (passed (> (get yes-votes proposal) (get no-votes proposal)))
      )
      (map-set proposals proposal-id
        (merge proposal { executed: true, passed: passed })
      )
      (ok passed)
    )
  )
)

(define-public (update-voting-power (member principal) (new-power uint))
  (let
    (
      (old-power (default-to u0 (map-get? member-voting-power member)))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-member member) ERR-NOT-MEMBER)
    (asserts! (> new-power u0) ERR-NOT-AUTHORIZED)
    (map-set member-voting-power member new-power)
    (var-set total-voting-power (+ (- (var-get total-voting-power) old-power) new-power))
    (ok true)
  )
)

(define-public (set-quorum-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (and (> new-percentage u0) (<= new-percentage u100)) ERR-INVALID-QUORUM)
    (var-set quorum-percentage new-percentage)
    (ok true)
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (is-member (account principal))
  (default-to false (map-get? members account))
)

(define-read-only (get-member-voting-power (member principal))
  (map-get? member-voting-power member)
)

(define-read-only (get-proposal-count)
  (var-get proposal-counter)
)

(define-read-only (get-member-count)
  (var-get member-counter)
)

(define-read-only (is-voting-active (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal (<= stacks-block-height (get end-block proposal))
    false
  )
)

(define-read-only (get-proposal-status (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (some {
      voting-active: (<= stacks-block-height (get end-block proposal)),
      total-votes: (+ (get yes-votes proposal) (get no-votes proposal)),
      yes-percentage: (if (> (+ (get yes-votes proposal) (get no-votes proposal)) u0)
                        (/ (* (get yes-votes proposal) u100) (+ (get yes-votes proposal) (get no-votes proposal)))
                        u0),
      executed: (get executed proposal),
      passed: (get passed proposal)
    })
    none
  )
)

(define-read-only (get-quorum-info (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (let
      (
        (total-votes (+ (get yes-votes proposal) (get no-votes proposal)))
        (required-quorum (/ (* (var-get total-voting-power) (var-get quorum-percentage)) u100))
      )
      (some {
        total-votes: total-votes,
        required-quorum: required-quorum,
        quorum-met: (>= total-votes required-quorum),
        participation-rate: (if (> (var-get total-voting-power) u0)
                             (/ (* total-votes u100) (var-get total-voting-power))
                             u0)
      })
    )
    none
  )
)

(define-read-only (get-contract-info)
  {
    owner: CONTRACT-OWNER,
    total-proposals: (var-get proposal-counter),
    total-members: (var-get member-counter),
    min-voting-period: MIN-VOTING-PERIOD,
    max-voting-period: MAX-VOTING-PERIOD,
    quorum-percentage: (var-get quorum-percentage),
    total-voting-power: (var-get total-voting-power)
  }
)

(begin
  (map-set members CONTRACT-OWNER true)
  (map-set member-voting-power CONTRACT-OWNER u100)
  (var-set member-counter u1)
  (var-set total-voting-power u100)
)