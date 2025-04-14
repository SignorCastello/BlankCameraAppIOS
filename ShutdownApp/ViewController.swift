import UIKit
import AVFoundation

class ViewController: UIViewController {
    private let shutdownButton = UIButton(type: .system)
    private var serverURL = "http://your-server-ip:5000/shutdown"
    private let urlTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Server URL text field
        urlTextField.placeholder = "http://192.168.1.44:5000/shutdown"
        urlTextField.borderStyle = .roundedRect
        urlTextField.text = serverURL
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlTextField)
        
        // Shutdown button
        shutdownButton.setTitle("Send Shutdown Signal", for: .normal)
        shutdownButton.backgroundColor = .systemRed
        shutdownButton.setTitleColor(.white, for: .normal)
        shutdownButton.layer.cornerRadius = 10
        shutdownButton.addTarget(self, action: #selector(sendShutdownSignal), for: .touchUpInside)
        shutdownButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shutdownButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            shutdownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutdownButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shutdownButton.widthAnchor.constraint(equalToConstant: 250),
            shutdownButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func sendShutdownSignal() {
        // Update server URL from text field
        if let url = urlTextField.text, !url.isEmpty {
            serverURL = url
        }
        
        guard let url = URL(string: serverURL) else {
            showAlert(message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // The payload expected by your Flask server
        let payload: [String: String] = ["status": "dark"]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            showAlert(message: "Error creating request: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showAlert(message: "Invalid response")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self?.showAlert(message: "Shutdown signal sent successfully")
                } else {
                    self?.showAlert(message: "Failed with status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}