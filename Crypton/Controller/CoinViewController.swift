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
    
    var coins = [Coins]()
    var cryptoCoins = [Coins]()
    
    var selectedFirstElement: String?
    var selectedSecondElement: String?
    
    var coinManager = CoinManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coinEUR = Coins()
        coinEUR.coinName = "EUR"
        coinEUR.coinViewName = "€ EUR"
        coins.append(coinEUR)
        
        let coinRUB = Coins()
        coinRUB.coinName = "RUB"
        coinRUB.coinViewName = "₽ RUB"
        coins.append(coinRUB)
        
        let coinUSD = Coins()
        coinUSD.coinName = "USD"
        coinUSD.coinViewName = "$ USD"
        coins.append(coinUSD)
        
        // Crypto
        let coinDOGE = Coins()
        coinDOGE.coinName = "DOGE"
        coinDOGE.coinViewName = "Ð DOGE"
        cryptoCoins.append(coinDOGE)
        
        let coinBTC = Coins()
        coinBTC.coinName = "BTC"
        coinBTC.coinViewName = "₿ BTC"
        cryptoCoins.append(coinBTC)
        
        let coinETH = Coins()
        coinETH.coinName = "ETH"
        coinETH.coinViewName = "Ξ ETH"
        cryptoCoins.append(coinETH)
        
        let coinLTC = Coins()
        coinLTC.coinName = "LTC"
        coinLTC.coinViewName = "Ł LTC"
        cryptoCoins.append(coinLTC)
        
        pickConvertCoin.reloadAllComponents()
        
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
                let coinCustom = Coins()
                
                coinCustom.coinName = coinTextField.text!
                
                if let coinSymbol = getSymbol(forCurrencyCode: coinTextField.text!) {
                    coinCustom.coinViewName = "\(coinSymbol) \(coinTextField.text!)"
                } else {
                    coinCustom.coinViewName = coinTextField.text!
                }

                self.coins.append(coinCustom)
            }

            if cryptoCoinTextField.text! != "" {
                let cryptoCoinCustom = Coins()
                cryptoCoinCustom.coinName = cryptoCoinTextField.text!
                cryptoCoinCustom.coinViewName = "\(getCrypoCoinSymbol(cryptoCoinTextField.text!)) \(cryptoCoinTextField.text!)"
                self.cryptoCoins.append(cryptoCoinCustom)
            }

            self.pickConvertCoin.reloadAllComponents()

        }
        
        alert.addTextField { (alertCryptoTextField) in
            alertCryptoTextField.placeholder = "BTC"
            alertCryptoTextField.autocapitalizationType = .allCharacters
            cryptoCoinTextField = alertCryptoTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "USD"
            alertTextField.autocapitalizationType = .allCharacters
            coinTextField = alertTextField
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
            return cryptoCoins[row].coinViewName //cryptoCoinsView[row]cryptoCoins
        } else {
            return coins[row].coinViewName //coinsView[row]
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            selectedFirstElement = cryptoCoins[row].coinName //cryptoCoins[row]
        } else {
            selectedSecondElement = coins[row].coinName
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
            leftLabel.text = cryptoCoins[row].coinViewName //cryptoCoinsView[row]
            leftLabel.textColor = .white
            leftLabel.textAlignment = .center
            leftLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.thin)
            view.addSubview(leftLabel)
        } else {
            rightLabel.text = coins[row].coinViewName
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

//MARK: - FileManager

func getCrypoCoinSymbol(_ inputName: String) -> String {
    
    var currencySymbol: String = ""
    
    if let url = Bundle.main.url(forResource: "CryptoCurrency", withExtension: "json") {
        
        do {
            let myData = try Data(contentsOf: url)
            let decodeData = try JSONDecoder().decode(Result.self, from: myData)
            for el in decodeData.data {
                if el.Code == inputName {
                    currencySymbol = el.Symbol // or uppercased()
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    return currencySymbol
}


func getSymbol(forCurrencyCode code: String) -> String? {
    
    let locale = NSLocale(localeIdentifier: code)
    
    if locale.displayName(forKey: .currencySymbol, value: code) == code {
        let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
        return newlocale.displayName(forKey: .currencySymbol, value: code)
    }
    return locale.displayName(forKey: .currencySymbol, value: code)
}
