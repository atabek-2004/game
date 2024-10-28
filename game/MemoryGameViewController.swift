//
//  MemoryGameViewController.swift
//  game
//
//  Created by Admin on 28.10.2024.
//

import UIKit

struct Card {
    let id: Int
    var isFlipped = false
    var isMatched = false
}

class MemoryGameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var timerLabel: UILabel!
    var movesLabel: UILabel!
    var bestResultLabel: UILabel!
    var collectionView: UICollectionView!
    var restartButton: UIButton!
    
    var timer: Timer?
    var secondsPassed: Int = 0
    var movesCount: Int = 0
    var bestResult: (time: Int, moves: Int)?
    var cards: [Card] = []
    var flippedCardIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("MemoryGameViewController loaded")
        setupUI()
        loadBestResult()
        startNewGame()
    }
    
    func setupUI() {

        timerLabel = UILabel()
        timerLabel.text = "00:00"
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        

        movesLabel = UILabel()
        movesLabel.text = "Moves: 0"
        movesLabel.textAlignment = .center
        movesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(movesLabel)
            bestResultLabel = UILabel()
        bestResultLabel.text = "Best: -"
        bestResultLabel.textAlignment = .center
        bestResultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bestResultLabel)
        

        restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart", for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(restartButton)

        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)


        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            movesLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 10),
            movesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bestResultLabel.topAnchor.constraint(equalTo: movesLabel.bottomAnchor, constant: 10),
            bestResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            restartButton.topAnchor.constraint(equalTo: bestResultLabel.bottomAnchor, constant: 10),
            restartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    @objc func restartGame() {
        print("Game restarted")
        startNewGame()
    }

    func startNewGame() {
        stopTimer()
        startTimer()
        movesCount = 0
        movesLabel.text = "Moves: \(movesCount)"
        cards = createShuffledCards()
        flippedCardIndex = nil
        collectionView.reloadData()
    }

    func createShuffledCards() -> [Card] {
        var cards: [Card] = []
        for i in 0..<8 { // 8 pairs
            let card1 = Card(id: i)
            let card2 = Card(id: i)
            cards.append(contentsOf: [card1, card2])
        }
        return cards.shuffled()
    }

    func startTimer() {
        timer?.invalidate()
        secondsPassed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.secondsPassed += 1
            self.updateTimerLabel()
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func updateTimerLabel() {
        let minutes = secondsPassed / 60
        let seconds = secondsPassed % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func incrementMoves() {
        movesCount += 1
        movesLabel.text = "Moves: \(movesCount)"
    }

    func saveBestResult() {
        if bestResult == nil || (secondsPassed < bestResult!.time) || (movesCount < bestResult!.moves) {
            bestResult = (time: secondsPassed, moves: movesCount)
            UserDefaults.standard.set(secondsPassed, forKey: "bestTime")
            UserDefaults.standard.set(movesCount, forKey: "bestMoves")
            updateBestResultLabel()
        }
    }

    func loadBestResult() {
        let bestTime = UserDefaults.standard.integer(forKey: "bestTime")
        let bestMoves = UserDefaults.standard.integer(forKey: "bestMoves")
        if bestTime > 0 && bestMoves > 0 {
            bestResult = (time: bestTime, moves: bestMoves)
            updateBestResultLabel()
        }
    }

    func updateBestResultLabel() {
        if let best = bestResult {
            let minutes = best.time / 60
            let seconds = best.time % 60
            bestResultLabel.text = "Best: \(String(format: "%02d:%02d", minutes, seconds)) / \(best.moves) moves"
        }
    }
    
    func checkGameCompletion() {
        if cards.allSatisfy({ $0.isMatched }) {
            stopTimer()
            saveBestResult()
            let minutes = secondsPassed / 60
            let seconds = secondsPassed % 60
            let alert = UIAlertController(
                title: "Поздравляем!",
                message: "Вы закончили игру за \(String(format: "%02d:%02d", minutes, seconds)) и \(movesCount) ходов!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let card = cards[indexPath.item]
        cell.configure(with: card)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCard = cards[indexPath.item]
        if selectedCard.isMatched || indexPath == flippedCardIndex { return }

        cards[indexPath.item].isFlipped.toggle()
        collectionView.reloadItems(at: [indexPath])
        
        if let previousIndex = flippedCardIndex {
            incrementMoves()
            if cards[previousIndex.item].id == selectedCard.id {
                cards[previousIndex.item].isMatched = true
                cards[indexPath.item].isMatched = true
                print("Matched cards: \(selectedCard.id)")
                flippedCardIndex = nil
                checkGameCompletion()
            } else {
                flippedCardIndex = indexPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.cards[indexPath.item].isFlipped = false
                    self.cards[previousIndex.item].isFlipped = false
                    self.flippedCardIndex = nil
                    self.collectionView.reloadItems(at: [indexPath, previousIndex])
                }
            }
        } else {
            incrementMoves()
            flippedCardIndex = indexPath
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 60) / 4
        return CGSize(width: width, height: width)
    }
}



class CardCell: UICollectionViewCell {
    private var cardView: UIView!
    private var cardLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCardView() {
        cardView = UIView()
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.cgColor
        cardView.backgroundColor = .blue
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        cardLabel = UILabel()
        cardLabel.textAlignment = .center
        cardLabel.textColor = .white
        cardLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            cardLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            cardLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])
    }

    func configure(with card: Card) {
        cardLabel.text = card.isFlipped || card.isMatched ? "\(card.id)" : "?"
        cardView.backgroundColor = card.isMatched ? .green : .blue
    }
}

