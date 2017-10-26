//
//  Pokemon.swift
//  pokedex-by-devslopes
//
//  Created by Leon Brown on 10/16/17.
//  Copyright © 2017 Leon Brown. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLvl: String!
    private var _pokemonUrl: String!
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        
        return _type
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        
        return _defense
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        
        return _attack
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        
        return _nextEvolutionTxt
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        
        return _nextEvolutionId
    }
    
    var nextEvolutionLvl: String {
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        
        return _nextEvolutionLvl
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        self._pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId!)/"
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        let url = URL(string: _pokemonUrl)!
        Alamofire.request(url).responseJSON { (response) -> Void in
            if let dict = response.result.value as? Dictionary<String, Any> {
                if let weight = dict["weight"] as? Int {
                    self._weight = "\(weight)"
                }
                
                if let height = dict["height"] as? Int {
                    self._height = "\(height)"
                }
                
                
                
                if let stats = dict["stats"] as? [Any] {
                    for stat in stats {
                        if let temp = stat as? Dictionary<String, Any> {
                            if let current = temp["stat"] as? Dictionary<String, String> {
                                if let name = current["name"] {
                                    if name == "attack" {
                                        if let attack = temp["base_stat"] as? Int {
                                            self._attack = "\(attack)"
                                        }
                                    } else if name == "defense" {
                                        if let defense = temp["base_stat"] as? Int {
                                            self._defense = "\(defense)"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                print(self._weight)
                print(self._height)
                print(self._attack)
                print(self._defense)
                
                if let types = dict["types"] as? [Dictionary<String, Any>], types.count > 0 {
                    if let type = types[0]["type"] as? Dictionary<String, String> {
                        if let name = type["name"] {
                            self._type = name.capitalized
                        }
                        
                        if types.count > 1 {
                            for x in 1...types.count - 1 {
                                if let type = types[x]["type"] as? Dictionary<String, String> {
                                    if let name = type["name"] {
                                        self._type! += "/\(name.capitalized)"
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                
                print(self._type)
                
                if let speciesDict = dict["species"] as? Dictionary<String, String> {
                    if let speciesUrlString = speciesDict["url"] {
                        let speciesUrl = URL(string: speciesUrlString)!
                        Alamofire.request(speciesUrl).responseJSON(completionHandler: { (response) in
                            self._description = ""
                            
                            if let responseData = response.result.value as? Dictionary<String, Any> {
                                if let flavor_text_entries = responseData["flavor_text_entries"] as? [Dictionary<String, Any>] {
                                    for flavor_text_entry in flavor_text_entries {
                                        if let flavor_language = flavor_text_entry["language"] as? Dictionary<String, String> {
                                            if let name = flavor_language["name"] {
                                                if name == "en" {
                                                    if let flavor_text = flavor_text_entry["flavor_text"] as? String {
                                                        self._description = flavor_text
                                                        completed()
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            print(self._description)
                        })
                    }
                }
                
                let evolutionUrlString = "\(URL_BASE)\(URL_EVOLUTION)\(self._pokedexId!)/"
                let evolutionUrl = URL(string: evolutionUrlString)!
                
                print(evolutionUrlString)
                
                Alamofire.request(evolutionUrl).responseJSON(completionHandler: { (response) in
                    //print(response.result.value)
                    
                    if let responseDict = response.result.value as? Dictionary<String, Any> {
                        if let evolutionChain = responseDict["chain"] as? Dictionary<String, Any> {
                            if let evolves_to = evolutionChain["evolves_to"] as? [Dictionary<String, Any>], evolves_to.count > 0 {
                                if let evolution_species = evolves_to[0]["species"] as? Dictionary<String, String> {
                                    if let to = evolution_species["name"] {
                                        
                                        // Can't support mega pokemon right now but
                                        // api still has mega data
                                        if to.range(of: "mega") == nil {
                                            if let evo_species_url_string = evolution_species["url"] {
                                                let newStr = evo_species_url_string.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                                
                                                let num = newStr.replacingOccurrences(of: "/", with: "")
                                                
                                                self._nextEvolutionId = num
                                                self._nextEvolutionTxt = to
                                                
                                                if let evolution_details = evolves_to[0]["evolution_details"] as? [Dictionary<String, Any>], evolution_details.count > 0 {
                                                    if let min_level = evolution_details[0]["min_level"] as? Int {
                                                        self._nextEvolutionLvl = "\(min_level)"
                                                    }
                                                }
                                                
                                                completed()
                                                
                                                print(self._nextEvolutionId)
                                                print(self._nextEvolutionTxt)
                                                print(self._nextEvolutionLvl)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}
