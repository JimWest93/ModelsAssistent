import UIKit

class SitesSettingsViewController: UIViewController {
    
    @IBOutlet weak var sitesInSettingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        sitesInSettingsTable.delegate = self
        sitesInSettingsTable.dataSource = self
        sitesInSettingsTable.tableFooterView = UIView()
        sitesInSettingsTable.backgroundColor = Color.shared.hex("#A1A5A6")
        view.backgroundColor = Color.shared.hex("#A1A5A6")
    }
    
    //кнопка для добавления сайта
    @IBAction func addSiteAction(_ sender: Any) {
        
        guard let addSiteVC = (storyboard?.instantiateViewController(identifier: "addSite")) as? AddSiteViewController else {return}
        
        addSiteVC.delegate = self
        
        self.present(addSiteVC, animated: true, completion: nil)
        
    }
    
}

extension SitesSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SiteForTable.currentSites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteInSettingsCell") as! SiteInSettingsCell
        cell.configureSiteInSettingsCell(data: MyRealm.realm.objects(SiteForTable.self)[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //переход на изменение выбранного сайта
        guard let addSiteVC = (storyboard?.instantiateViewController(identifier: "addSite")) as? AddSiteViewController else {return}

        addSiteVC.addSiteItems = ItemsToChangeSite.itemsToChangeSite(data: SiteForTable.currentSites[indexPath.row])
        addSiteVC.delegate = self
        addSiteVC.changingTheSite = true
        addSiteVC.indexOfSiteInRealm = indexPath.row
        addSiteVC.validationCheck()
        
        self.present(addSiteVC, animated: true, completion: nil)
        
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //удаление сайта
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (contextualAction, view, boolValue) in
            
            let site = SiteForTable.currentSites[indexPath.row]
            
            try! MyRealm.realm.write{
                
                MyRealm.realm.delete(site)
                self.sitesInSettingsTable.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
        
    }
    
}

//делегат добавления сайта
extension SitesSettingsViewController: sitesInSettingsDelegate {
    func reloadData() {
        self.sitesInSettingsTable.reloadData()
    }
}
