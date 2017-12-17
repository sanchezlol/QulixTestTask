//
//  ViewController.swift
//  QulixBarodzichTest
//
//  Created by Alexandr on 12/12/17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit


class GoogleSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    private var links : Array<String> = []
    private var currentTask: URLSessionTask = URLSessionTask()
    var requestIsProcessing = false
    
    let requestQueue = DispatchQueue.global(qos: .userInitiated)
    let parseQueue = DispatchQueue.global(qos: .userInteractive)
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        cell.textLabel!.text = links[indexPath.row]
        return cell
    }

    private func search(){
        
        queryTextField.endEditing(true)
        
        requestIsProcessing = true
        
        if let url = generateUrl(forQuery: queryTextField.text!){
            
            self.currentTask = URLSession.shared.dataTask(with: url) {
                
            (data, response, error) in
            
            guard let data = data else { return }
                do {
                    try self.parseQueue.sync {
                        let content = try JSONDecoder().decode(GoogleResponse.self, from: data)

                        if content.items != nil {
                            self.links.removeAll()
                            content.items!.forEach{
                                print($0.link)
                                self.links.append($0.link)
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else if content.error?.code != nil {
                            self.showToast(message: "Connection error: \(content.error!.code)")
                        }
                    }
                } catch {
                    print(error)
                }
                self.setUINormal()
                self.requestIsProcessing = false
            }
            
            requestQueue.async {
                self.setUIProcessing()
                self.currentTask.resume()
            }
        } else {
            print("Invalid url")
        }
        
    
    }
    private func stopSearch(){
        self.requestQueue.async {
            self.currentTask.cancel()
        }
        print("Search stopped")
        self.requestIsProcessing = false
        setUINormal()
    }
    
    
    private func handleButton(){
        if !requestIsProcessing {
            search()
        } else {
            stopSearch()
        }
    }
    
    private func setUIProcessing(){
        DispatchQueue.main.async {
            self.searchButton.setTitle("Stop", for: .normal)
            self.spinner.isHidden = false
            self.spinner.startAnimating()
        }
    }
    private func setUINormal(){
        DispatchQueue.main.async {
            self.searchButton.setTitle("Google Search", for: .normal)
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.isHidden = true
        searchButton.setTitle("Google Search", for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissText))
        view.addGestureRecognizer(tapGesture)
        
        queryTextField.returnKeyType = UIReturnKeyType.search
        queryTextField.delegate = self
        
    }
    
    private func generateUrl(forQuery query: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.path = "/customsearch/v1"
        
        let queryItem1 = URLQueryItem(name: "key", value: "AIzaSyAH3_lHl7jethKBhhVYE2T4CVTtywlAnyw")
        //Invalid key for error test
//        let queryItem1 = URLQueryItem(name: "key", value: "AIzaSyAH3_lHl7jethKBhhVYE2T4CVTtywlAny")
        let queryItem2 = URLQueryItem(name: "cx", value: "008731617817981143287:dvigwxbstw0")
        let queryItem3 = URLQueryItem(name: "q", value: query)
        
        components.queryItems = [queryItem1, queryItem2, queryItem3]
        
        if let url : URL = components.url {
            print("Query url: " + String(describing: components.url!))
            return url
        } else {
            return nil
        }
    }

    private func showToast(message : String) {
        DispatchQueue.main.async {
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
    @IBAction func pressSearchButton(_ sender: UIButton) {
        handleButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.queryTextField {
            handleButton()
        }
        return true
    }
    
    @objc func dismissText(){
        queryTextField.endEditing(true)
    }
}

