//
//  WeatherViewModel.swift
//  apicall
//
//  Created by vidio on 13/05/24.
//

import Foundation



struct WeatherResponse : Decodable {
	let location: WeatherLocation
	let current: CurrentWeather
}

struct WeatherLocation : Decodable {
	let name: String
	let country: String
}

struct CurrentWeather : Decodable {
	let temp_c: Double
	let condition: Condition
	let feelslike_c: Double
	
}

struct Condition : Decodable {
	let text: String
	let icon: String
}

class WeatherViewModel : ObservableObject {
	
	@Published
	var temperature: Double
	
	private let apiKey = "ecb3b00cde4d442c925225620241205"
	
	private var currentCountry = ""
	
	init() {
		temperature = 0
	}
	
	func selectCountry(_ country: String) {
		currentCountry = country
	}
	
	func getWeatherData(onResponseSuccess: @escaping (WeatherResponse) -> Void) {
		print("puyo >>> createURL")
		guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(currentCountry)&aqi=no") else {
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		print("puyo >>> initiating URLSession")
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard data != nil else {
				print("data is nil")
				return
			}
			
			let decoder = JSONDecoder()
			
			do {
				let weatherResponse = try decoder.decode(WeatherResponse.self, from: data!)
				
				print("puyo >>> \(String(describing: weatherResponse))")
				
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
					onResponseSuccess(weatherResponse)
				}
			} catch {
				print("puyo >>> Unexpected error occured \(error)")
				guard let urlResponse = response as? HTTPURLResponse else {
					return
				}
				print("puyo >>> http statusCode \(urlResponse.statusCode)")
			}
		}
		
		task.resume()
	}
	
	func removeSuffix(from: String, suffixCharacter character: Character) -> String {
		var parsedString = from
		
		while true {
			let firstChar = parsedString[parsedString.startIndex]
			
			if !parsedString.isEmpty && firstChar == character {
				parsedString.remove(at: parsedString.startIndex)
			} else {
				break
			}
		}
		
		return parsedString
	}
	
	func appendHttpsProtocolIfNeeded(_ url: String) -> String {
		if url.contains("https:") {
			return url
		} else {
			return "https:" + url
		}
	}
}
