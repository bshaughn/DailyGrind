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
    
   // var wkWebBrew:WKWebView!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let mainWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        mainWebView.backgroundColor = .blueColor()
        mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: "https://google.com")!))
        
        self.view.addSubview(mainWebView)
        */
        
        browser.delegate = self
        browser.startSearchingForNewAccessories()
        
        homeManager.delegate = self
        
        //welcomeView = UIView(frame: CGRect(x: 100, y: 100, width: 250, height: 100))
        //welcomeView.backgroundColor = UIColor.yellowColor()
        //self.view.addSubview(welcomeView)
        
        brewButton = UIButton(type: .System) as UIButton
       // brewButton = UIButton(frame: CGRect(x: 100, y: 100, width: 250, height: 100))
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
                /*
                if self.homeManager.homes.count > 1 {
                for h in self.homeManager.homes {
                    self.homeManager.removeHome(h, completionHandler: { (err) -> Void in
                        print("removed \(h.name)")
                    })
                }
                }
                */
                
                if self.homeManager.homes.count > 0 {
                  //  print("has \(self.homeManager.homes.count) homes already!")
                    self.homeManager.updatePrimaryHome(self.homeManager.homes[0], completionHandler: { (error) -> Void in
                     //   print("assigned Primary home to existing HC")
                     //   print("Primary Home accessories: \(self.homeManager.primaryHome?.accessories)")
                     //   print("Accessory: \(self.homeManager.primaryHome?.accessories[0].services)")
                        self.coffeeMaker = self.homeManager.primaryHome?.accessories[0]
                        self.brewButton.backgroundColor = .orangeColor()
                        self.brewButton.setTitle("Brew me some coffee!", forState: .Normal)
                        self.brewButton.titleLabel?.textColor = .blackColor()
                        self.brewButton.enabled = true
                        self.brewButton.userInteractionEnabled = true
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
    
    func startMakingCoffee(sender:UIButton) {
        print("Start making coffee")
      //  print("characteristics: \(coffeeMaker?.services[0].characteristics)")
      //  print(coffeeMaker?.services[0].characteristics)
      //  print(coffeeMaker?.services[1].characteristics.count)
      //  print(coffeeMaker?.services.count)
     //   var onSwitch = ((coffeeMaker?.services[1].characteristics[1])! as HMCharacteristic).value as! Int
        
     //   var inUse = ((coffeeMaker?.services[1].characteristics[1])! as HMCharacteristic).value as! Int
      //  inUse = true
      //  onSwitch = false
        
        var power_state = coffeeMaker?.services[1].characteristics[1].metadata?.manufacturerDescription
        var outlet_in_use = coffeeMaker?.services[1].characteristics[2].metadata?.manufacturerDescription
        
        
//        for c in (coffeeMaker?.services[1].characteristics)! {
//            print(c.metadata)
//            c.readValueWithCompletionHandler({ (err) -> Void in
//                print(c.value)
//            })
//        }
        
        coffeeMaker?.services[1].characteristics[1].writeValue(1, completionHandler: { (err) -> Void in
            self.coffeeMaker?.services[1].characteristics[2].writeValue(1, completionHandler: { (err) -> Void in
                print("updated plug characteristics")
                
               // self.brewButton.alpha = 0
                
                /*
                let wkWebBrew = WKWebView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width, height: self.view.frame.height))
                wkWebBrew.backgroundColor = .purpleColor()
             //   wkWebBrew.loadRequest(NSURLRequest(URL: NSURL(string: "https://google.com")!))
                wkWebBrew.loadRequest(NSURLRequest(URL: NSURL(fileReferenceLiteral: "index.html")))
                
                self.view.addSubview(wkWebBrew)
                */
                
                let brewView = UIWebView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width, height: self.view.frame.height))
                brewView.backgroundColor = .purpleColor()
                //   wkWebBrew.loadRequest(NSURLRequest(URL: NSURL(string: "https://google.com")!))
                brewView.loadRequest(NSURLRequest(URL: NSURL(fileReferenceLiteral: "index.html")))
                
                self.view.addSubview(brewView)
            })
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic) {
        print("updated characteristc")
       
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        print("found stuff!")
        print(accessory.name)
       // var err:NSError?
        
        
        
        accessory.delegate = self
        
       // if homeManager.homes.count > 0 {
      //  if homeManager.primaryHome != nil {
       // homeManager.homes[0].addAccessory(accessory) { (err) -> Void in
            homeManager.primaryHome!.addAccessory(accessory, completionHandler: { (error) -> Void in
                print("added accessory")
                
                self.brewButton.backgroundColor = .orangeColor()
                self.brewButton.setTitle("Brew me some coffee!", forState: .Normal)
                self.brewButton.titleLabel?.textColor = .blackColor()
                self.brewButton.enabled = true
                self.brewButton.userInteractionEnabled = true
                
                self.coffeeMaker = accessory
                
                var services = accessory.services
              //  print("Services: \(services)")
                
                var isReachable = accessory.reachable
                
                var ch = self.coffeeMaker?.services
                
            })
       // }
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        print("removed stuff!")
    }
    
    func updateControllerWithHome(home: HMHome) {
        if let room = home.rooms.first as HMRoom? {
            activeRoom = room
            title = room.name + " Devices"
        }
    }
    
    func accessoryDidUpdateServices(accessory: HMAccessory) {
        print("updated accessory services")
    }
    
    func accessoryDidUpdateReachability(accessory: HMAccessory) {
        print("updated reachability")
    }
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
       // print("updated homes")
    }

}

