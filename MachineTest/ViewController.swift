//
//  ViewController.swift
//  MachineTest
//
//  Created by test on 07/02/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: Variables
    var employeeData: NSArray = []
    @IBOutlet weak var searchtxt: UITextField!
    @IBOutlet weak var lisTbl: UITableView!
    
    // MARK: ViewCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        retrieveData()
    }
    
    // MARK: Functions
    func getEmployeeDetails() {
        let url = "http://www.mocky.io/v2/5d565297300000680030a986"
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, res, err) in
            
            do {
                // ensure there is no error for this HTTP response
                guard err == nil else {
                    print ("error: \(err!)")
                    return
                }
                
                // ensure there is data returned from this HTTP response
                guard let content = data else {
                    print("No data")
                    return
                }
                
                // serialise the data / NSData object into Dictionary [String : Any]
                do {
                    if let results = try JSONSerialization.jsonObject(with: content) as? [[String:Any]] {
                        // results is now an array of dictionary, access what you need
                        print(results)
                        self.storeEmplyeeDetails(array: results as NSArray)
                    } else {
                        print("JSON was not the expected array of dictonary")
                    }
                } catch {
                    print("Can't process JSON: \(error)")
                }
                
            }
        }.resume()
    }
    func storeEmplyeeDetails(array: NSArray){
        print(array)
        print(array.count)
        
             let appDelegate = UIApplication.shared.delegate as? AppDelegate
        //We need to create a context from this container
        let managedContext = appDelegate!.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        
        
        //final, we need to add some data to our newly created record for each keys using
        for i in 0..<array.count{
            let userEntity = NSEntityDescription.entity(forEntityName: "Employee", in: managedContext)!
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            let data = array.object(at:i) as? NSDictionary ?? [:]
            
            let company = data["company"] as? NSDictionary ?? [:]
            let address = data["address"] as? NSDictionary ?? [:]
            print(company,address)
            
            user.setValue("\(data["name"] ?? "")", forKeyPath: "name")
            user.setValue("\(address["city"] ?? "")\(",")\(address["street"] ?? "")\(",")\(address["suite"] ?? "")\(",")\(address["zipcode"] ?? "")", forKeyPath: "address")
            user.setValue("\(company["name"] ?? "")\(",")\(company["catchPhrase"] ?? "")\(",")\(company["name"] ?? "")",forKeyPath: "comanyDetails")
            user.setValue("\(company["name"] ?? "")",forKeyPath: "comanyName")
            user.setValue("\(data["email"] ?? "")",forKeyPath: "email")
            user.setValue("\(data["id"] ?? "")",forKeyPath: "id")
            user.setValue("\(data["phone"] ?? "")",forKeyPath: "phone")
            user.setValue("\(data["profile_image"] ?? "")",forKeyPath: "profileImage")
            user.setValue("\(data["username"] ?? "")", forKey: "username")
            user.setValue("\(data["website"] ?? "")", forKey: "website")
            
            do {
                try managedContext.save()
               
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        self.retrieveData()
    }
    
    //MARK:- FOR RETRIEVING OR FETCHING THE DATA
    func retrieveData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count == 0{
                self.getEmployeeDetails()
            }else{
                self.employeeData = result as NSArray
                DispatchQueue.main.async {
                    self.lisTbl.reloadData()
                }

            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    func filterData(text: String)
    {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        let predicate = NSPredicate(format: "(name CONTAINS %@) OR (email CONTAINS %@)", text,text)
        fetchRequest.predicate = predicate
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count == 0{
                
            }else{
                self.employeeData = result as NSArray
                DispatchQueue.main.async {
                    self.lisTbl.reloadData()
                }

            }
            
        } catch {
            
            print("Failed")
        }
    }
    
}

class EmployeeListCell: UITableViewCell{
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var comapnyLbl: UILabel!
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "EmployeeListCell", for: indexPath) as? EmployeeListCell)!
        let data: NSManagedObject = employeeData[indexPath.row] as! NSManagedObject


        cell.nameLbl.text = "\(data.value(forKey: "name") ?? "NA")"
        cell.comapnyLbl.text = "\(data.value(forKey: "comanyName") ?? "NA")"
       
        let url = URL(string: "\(data.value(forKey: "profileImage") ?? "https://randomuser.me/api/portraits/men/1.jpg")")
        if url != nil{
            let dataImage = try? Data(contentsOf: url!)

            if let imageData = dataImage {
                let image = UIImage(data: imageData)
                cell.profileIcon.image = image
            }
        }else{
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data: NSManagedObject = employeeData[indexPath.row] as! NSManagedObject
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailView = storyBoard.instantiateViewController(withIdentifier: "EmployeeDetails") as! EmployeeDetails

        detailView.id = "\(data.value(forKey: "id") ?? "0")"
        self.navigationController?.pushViewController(detailView, animated: true)

    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.count == 0{
            self.retrieveData()
        }else{
            self.filterData(text: textField.text ?? "")
        }
        
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentString: NSString = textField.text! as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        self.filterData(text: newString as String)
//        return true
//
//    }
}
