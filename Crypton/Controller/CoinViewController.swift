//
//  ViewController.swift
//  Crypton
//
//  Created by Alexandr on 28.11.2021.
//

import UIKit
import CoreLocation
import CoreML

class CoinViewController: UIViewController {
    
    @IBOutlet weak var pickConvertCoin: UIPickerView!
    @IBOutlet weak var coinLabel: UILabel!
    
    // Coin views
    var coinsView = ["€ EUR", "₽ RUB", "$ USD"]
    var cryptoCoinsView = ["Ð DOGE", "₿ BTC", "Ξ ETH", "Ł LTC"]
    // Coin names
    var coins = ["EUR", "RUB", "USD"]
    var cryptoCoins = ["DOGE", "BTC", "ETH", "LTC"]
    
    var selectedFirstElement: String?
    var selectedSecondElement: String?
    
    var coinManager = CoinManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Delegate
        coinManager.delegate = self
        
        // Connect data:
        pickConvertCoin.dataSource = self
        pickConvertCoin.delegate = self

        pickerView(pickConvertCoin, didSelectRow: 1, inComponent: 1)
        pickConvertCoin.selectRow(1, inComponent: 1, animated: true)
        pickConvertCoin.selectRow(1, inComponent: 0, animated: true)
    }
    
    
    @IBAction func AddCoinItem(_ sender: UIBarButtonItem) {
        
        var coinTextField = UITextField()
        var cryptoCoinTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Coin", message: "format is ABC", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Set", style: .default) { (action) in
            
            if coinTextField.text! != "" {
                self.coins.append(coinTextField.text!)
                self.coinsView.append(coinTextField.text!)
            }
            
            if cryptoCoinTextField.text! != "" {
                self.cryptoCoins.append(cryptoCoinTextField.text!)
                self.cryptoCoinsView.append(cryptoCoinTextField.text!)
            }
            
            self.pickConvertCoin.reloadAllComponents()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "USD"
            alertTextField.autocapitalizationType = .allCharacters
            coinTextField = alertTextField
        }
        alert.addTextField { (alertCryptoTextField) in
            alertCryptoTextField.placeholder = "BTC"
            alertCryptoTextField.autocapitalizationType = .allCharacters
            cryptoCoinTextField = alertCryptoTextField
        }
        
        alert.message = "Input format"
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

//MARK: - UIPickerViewDelegate
extension CoinViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return cryptoCoins.count
        } else {
            return coins.count
        }
        
    }
    
    //MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return cryptoCoinsView[row]
        } else {
            return coinsView[row]
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            selectedFirstElement = cryptoCoins[row]
        } else {
            selectedSecondElement = coins[row]
        }
        
        let firstCoin = selectedFirstElement ?? "BTC"
        let secondCoin = selectedSecondElement ?? "RUB"
        
        coinManager.fetchExchangeRate(firstCoin, to: secondCoin)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100.0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let rightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        if component == 0 {
            leftLabel.text = cryptoCoinsView[row]
            leftLabel.textColor = .white
            leftLabel.textAlignment = .center
            leftLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.thin)
            view.addSubview(leftLabel)
        } else {
            rightLabel.text = coinsView[row]
            rightLabel.textColor = .white
            rightLabel.textAlignment = .center
            rightLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.thin)
            view.addSubview(rightLabel)
        }

        return view
    }
    
}

//MARK: - CoinManagerDelegate
extension CoinViewController: CoinManagerDelegate {
    
    func didUpdateRate(_ coinManager: CoinManager, rate: Double) {
        DispatchQueue.main.async {
            self.coinLabel.text = "\(rate) \(self.selectedSecondElement ?? "")"
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
