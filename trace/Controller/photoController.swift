//
//  photoController.swift
//  trace
//
//  Created by ITP312 on 1/8/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class photoController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {

    var prefixofpictures: [String] = []
    var suffixofpictures: [String] = []
    var placeid : String?
    var fulllink: [String] = []
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    override func viewDidLoad() {
        getphotos(self.placeid!)
                super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        for i in 0..<prefixofpictures.count{
            var linku = prefixofpictures[i] + "500x500" + suffixofpictures[i]
            fulllink.append(linku)
        }
        print(fulllink)

        collectionview.reloadData()

    }
    func getphotos(_ placeid: String){
        var ids = placeid as? String ?? "nil"
        if ids != "nil"{
            guard var url = URL(string: "https://api.foursquare.com/v2/venues/\(ids)?client_id=E1TG2A34J4T5VG2PTDF5U1D3MYP2ABQ0410WLXYNLMPIYCGV&client_secret=WEEA0K5KPAAFIOFABHDTY2PHZMD54AUBRKBAVL0IMHUKXO3F&v=20190715") else {return}
            
            var session = URLSession.shared
            session.dataTask(with: url){(data,response,error) in
                if var response = response {}
                if var data = data {
                    do {
                        var output = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        let photo = output["response"] as! NSDictionary
                        let photo2  = photo["venue"] as! NSDictionary
                        let photo3 = photo2["photos"] as! NSDictionary
                        let photo4 = photo3["groups"] as! NSArray
                        let photo5 = photo4[1] as! NSDictionary
                        let photo6 = photo5["items"] as! NSArray
                        print(photo6)
                        for i in 0..<photo6.count{
                            let photo7 = photo6[i] as! NSDictionary
                            self.prefixofpictures.append(photo7["prefix"] as! String)
                            self.suffixofpictures.append(photo7["suffix"] as! String)
                        }
                    }catch{print(error)}
                }
            }.resume()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fulllink.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            cell.mycell.image = UIImage(named: fulllink[indexPath.row])
            return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

