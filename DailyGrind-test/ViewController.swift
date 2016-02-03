//
//  ViewController.swift
//  DailyGrind-test
//
//  Created by Bart Shaughnessy on 1/21/16.
//  Copyright © 2016 DopeTech. All rights reserved.
//

import UIKit
import HomeKit
import WebKit

class ViewController: UIViewController, HMHomeManagerDelegate, HMHomeDelegate, HMAccessoryDelegate, HMAccessoryBrowserDelegate, UIWebViewDelegate {
    var activeRoom:HMRoom?
    var homeManager = HMHomeManager()
    var browser = HMAccessoryBrowser()
    var accessories = [HMAccessory]()
    
    var brewButton:UIButton!
    var coffeeMaker:HMAccessory?
    
     override func viewDidLoad() {
        super.viewDidLoad()
        browser.delegate = self
        browser.startSearchingForNewAccessories()
        
        homeManager.delegate = self
        brewButton = UIButton(type: .System) as UIButton
        brewButton.frame = CGRect(x: 100, y: 100, width: 250, height: 100)
        brewButton.backgroundColor = .grayColor()
        brewButton.setTitle("Looking for outlet...", forState: .Normal)
        brewButton.titleLabel?.textColor = .blackColor()
        brewButton.enabled = false
        
        brewButton.addTarget(self, action: "startMakingCoffee:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(brewButton)
        
        if homeManager.homes.count > 0 {
            print("has homes already!")
        }
        
        homeManager.addHomeWithName("myHome", completionHandler: { (home, error) -> Void in
            if error != nil {
                home?.delegate = self
                
                if self.homeManager.homes.count > 0 {
                    self.homeManager.updatePrimaryHome(self.homeManager.homes[0], completionHandler: { (error) -> Void in
                        self.coffeeMaker = self.homeManager.primaryHome?.accessories[0]
                        self.activateBrewButton()
                    })
                }
                
                print("Something went wrong when attempting to create our home. \(error!.localizedDescription)")
            } else {
                // Add a new room to our home
                home!.addRoomWithName("Office", completionHandler: { (room, error) -> Void in
                    if error != nil {
                        print("Something went wrong when attempting to create our room. \(error!.localizedDescription)")
                    } else {
                        self.updateControllerWithHome(home!)
                    }
                })
                
                // Assign this home as our primary home
                self.homeManager.updatePrimaryHome(home!, completionHandler: { (error) -> Void in
                    if error != nil {
                        print("Something went wrong when attempting to make this home our primary home. \(error!.localizedDescription)")
                    }
                })
            }
        })
    }
    
    // MARK: Custom Methods
    func startMakingCoffee(sender:UIButton) {
        print("Start making coffee")
        
        coffeeMaker?.services[1].characteristics[1].writeValue(1, completionHandler: { (err) -> Void in
            self.coffeeMaker?.services[1].characteristics[2].writeValue(1, completionHandler: { (err) -> Void in
                print("updated plug characteristics")
                
                let brewView = UIWebView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width, height: self.view.frame.height))
                brewView.backgroundColor = .purpleColor()
                
                let baseUrl = NSBundle.mainBundle().bundleURL
                let path = NSBundle.mainBundle().pathForResource("index", ofType: "html")
                let HTMLString: NSString?
                
                do {
                    HTMLString = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                    brewView.loadHTMLString(HTMLString as! String, baseURL: baseUrl )
                    
                } catch {
                    HTMLString = nil
                }
                
                self.view.addSubview(brewView)
            })
        })
        
    }
    
    func updateControllerWithHome(home: HMHome) {
        if let room = home.rooms.first as HMRoom? {
            activeRoom = room
            title = room.name + " Devices"
        }
    }
    
    func activateBrewButton() {
        self.brewButton.backgroundColor = .orangeColor()
        self.brewButton.setTitle("Brew me some coffee!", forState: .Normal)
        self.brewButton.titleLabel?.textColor = .blackColor()
        self.brewButton.enabled = true
        self.brewButton.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Accessory delegate methods
    func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic) {
        print("updated characteristc")
       
    }
    
    func accessoryDidUpdateServices(accessory: HMAccessory) {
        print("updated accessory services")
    }
    
    func accessoryDidUpdateReachability(accessory: HMAccessory) {
        print("updated reachability")
    }
    
    // MARK: Accessory Browser Delegate methods
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        accessory.delegate = self
        
        homeManager.primaryHome!.addAccessory(accessory, completionHandler: { (error) -> Void in
            print("added accessory")
            self.activateBrewButton()
            self.coffeeMaker = accessory
        })
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        print("removed stuff!")
    }
    
    // MARK: HomeManager Delegate Methods
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
       // print("updated homes")
    }
}

