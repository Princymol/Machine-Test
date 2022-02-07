//
//  EmployeeDetails.swift
//  MachineTest
//
//  Created by test on 07/02/22.
//

import UIKit
import CoreData

class EmployeeDetails: UIViewController {
    // MARK: Variables
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var employeeDetails: UILabel!
    var employeeData: NSArray = []
    var id: String = ""
    
    // MARK: ViewCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getEmplyeeDetails()
    }
    
    // MARK: Functions
    
    func getEmplyeeDetails(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        let predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count == 0{
                print("nodata")
            }else{
                self.employeeData = result as NSArray
                if self.employeeData.count != 0{
                    let data: NSManagedObject = employeeData[0] as! NSManagedObject
                    self.employeeDetails.text = "Name: \(data.value(forKey: "name") ?? "NA")\nUser Name: \(data.value(forKey: "username") ?? "NA")\nEmail Address: \(data.value(forKey: "email") ?? "NA")\nAddress: \(data.value(forKey: "address") ?? "NA")\nPhone: \(data.value(forKey: "phone") ?? "NA")\nWebsite: \(data.value(forKey: "website") ?? "NA")\nCompany Details: \(data.value(forKey: "comanyDetails") ?? "NA")"
                   

                    let url = URL(string: "\(data.value(forKey: "profileImage") ?? "https://randomuser.me/api/portraits/men/1.jpg")")
                    if url != nil{
                        let dataImage = try? Data(contentsOf: url!)
                        
                        if let imageData = dataImage {
                            let image = UIImage(data: imageData)
                            self.profileIcon.image = image
                        }
                    }else{
                        
                    }
                }
            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
