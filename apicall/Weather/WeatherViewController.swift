//
//  ViewController.swift
//  apicall
//
//  Created by vidio on 13/05/24.
//

import UIKit

class WeatherViewController:
	UIViewController,
	UIPickerViewDelegate,
	UIPickerViewDataSource
{

	@IBOutlet weak var labelLocation: UILabel!
	@IBOutlet weak var labelWeatherTemperature: UILabel!
	@IBOutlet weak var labelWeatherCondition: UILabel!
	@IBOutlet weak var buttonLoadData: UIButton!
	@IBOutlet weak var imageWeatherCondition: UIImageView!
	@IBOutlet weak var indicatorWeatherConditionIcon: UIActivityIndicatorView!
	@IBOutlet weak var indicatorWeatherData: UIActivityIndicatorView!
	@IBOutlet weak var pickerCountry: UIPickerView!
	
	private let viewModel = WeatherViewModel()
	
	var pickerData: [String] = [String]()
	
	override func loadView() {
		super.loadView()
		pickerData = ["Jakarta", "Depok", "Cirebon", "Bekasi", "Bandung"]
		
		self.indicatorWeatherData.hidesWhenStopped = true
		self.indicatorWeatherConditionIcon.hidesWhenStopped = true
		self.pickerCountry.delegate = self
		self.pickerCountry.dataSource = self
		self.pickerView(self.pickerCountry, didSelectRow: 0, inComponent: 0)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		buttonLoadData.addTarget(
			self,
			action: #selector(self.actionLoadData),
			for: .touchUpInside
		)
	}
	
	@objc func actionLoadData(sender: UIButton!) {
		labelWeatherTemperature.isHidden = true
		labelLocation.isHidden = true
		labelWeatherCondition.isHidden = true
		imageWeatherCondition.isHidden = true
		indicatorWeatherData.startAnimating()
		
		viewModel.getWeatherData { response in
			self.labelWeatherTemperature.text = "\(response.current.temp_c)°"
			self.labelLocation.text = "\(response.location.name), \(response.location.country)"
			self.labelWeatherCondition.text = response.current.condition.text
			
			self.labelWeatherTemperature.isHidden = false
			self.labelLocation.isHidden = false
			self.labelWeatherCondition.isHidden = false
			
			self.indicatorWeatherData.stopAnimating()


			self.indicatorWeatherConditionIcon.startAnimating()
			let iconUrl = self.viewModel.appendHttpsProtocolIfNeeded(
				response.current.condition.icon
			)
			
			self.loadImageFromUrl(iconUrl)
		}
	}
	
	func loadImageFromUrl(_ url: String) {
		guard let url = URL(string: url) else { return }
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			print("puyo >>> load icon from:: \(url)")
			guard let data = data, error == nil else { return }
			
			DispatchQueue.main.async { /// execute on main thread
				let uiImage = UIImage(data: data)
				
				self.indicatorWeatherConditionIcon.stopAnimating()
				
				self.imageWeatherCondition.image = uiImage
				self.imageWeatherCondition.isHidden = false
			}
		}
		
		task.resume()
	}
	
	// Picker delegates
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let selectedCountry = pickerData[row]
		viewModel.selectCountry(selectedCountry)
		
		print("puyo >>> selectedCountry: \(selectedCountry)")
	}
}
