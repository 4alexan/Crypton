//
//  CoinManager.swift
//  Crypton
//
//  Created by Alexandr on 30.11.2021.
//

// https://stackoverflow.com/questions/31999748/get-currency-symbols-from-currency-code-with-swift
// help for symbol

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRate(_ coinManager: CoinManager, rate: Double)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    // Delegate
    var delegate: CoinManagerDelegate?
    
    let coinURL = "https://rest.coinapi.io/v1/exchangerate"
//    let assetsURL = "https://rest.coinapi.io/v1/assets"

    func fetchExchangeRate(_ from: String, to: String) {
        
        let apiKey = ""
        let finalURL = "\(coinURL)/\(from)/\(to)?apikey=\(apiKey)&output_format=json"
        
        // Perform request URL
        performRequest(with: finalURL)
        
    }
    
    
    func performRequest(with finalURL: String) {
        
        // 1. Create a URL
        if let url = URL(string: finalURL) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default) // Or URLSession.shared // Or URLSession.shared.dataTask(with: url)
            
            let task = session.dataTask(with: url) {(data, response, error) in
                
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let exchangeRate = self.parseJSON(safeData) {
                        self.delegate?.didUpdateRate(self, rate: exchangeRate)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
        
    }
    
    
    func parseJSON(_ coinData: Data) -> Double? {
        
        let decoder = JSONDecoder()
        
        do {
            let decodeData = try decoder.decode(CoinData.self, from: coinData)
            let rate = Double(round(100 * decodeData.rate) / 100)
            return rate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

}
