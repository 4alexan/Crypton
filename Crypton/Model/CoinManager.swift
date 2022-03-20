//
//  CoinManager.swift
//  Crypton
//
//  Created by Alexandr on 30.11.2021.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRate(_ coinManager: CoinManager, rate: Double)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    // Delegate
    var delegate: CoinManagerDelegate?
    
    let coinURL = "https://rest.coinapi.io/v1/exchangerate"

    func fetchExchangeRate(_ from: String, to: String) {
        
        let finalURL = "\(coinURL)/\(from)/\(to)?apikey=&output_format=json"
        
        // Выполнить запрос по URL
        performRequest(with: finalURL)
        
    }
    
    
    func performRequest(with finalURL: String) {
        
        // 1. Create a URL
        if let url = URL(string: finalURL) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default) // Or URLSession.shared
            
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
