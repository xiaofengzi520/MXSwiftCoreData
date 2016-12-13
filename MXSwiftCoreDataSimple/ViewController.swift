//
//  ViewController.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/8.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit
import MXSwiftCoreData
import CoreData

public class PhotoCell:UITableViewCell{
    var photo:Photo?;
}

extension PhotoCell:MXCellConfigurableDelegate{
    public func configureForObject(_ object: Photo){
        self.photo = object;
        imageView?.image = object.image;
        textLabel?.text = "imageSize = \(object.width)*\(object.height)";
        detailTextLabel?.text = "date:\(object.date)";
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let identifier = "Identifier";
    typealias Data = MXFetchedResultsDataProvider<Photo,ViewController>
    var dataSource: MXTableViewDataSource<ViewController, Data, PhotoCell>!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.register(PhotoCell.self, forCellReuseIdentifier: identifier)
        let request:NSFetchRequest<Photo> = Photo.sortedFetchRequest();
        request.fetchBatchSize = 20;
        let context = AppDelegate.defalut.managerContext!;
        let dataProvider = MXFetchedResultsDataProvider(request, managedObjectContext: context, delegate: self);
        dataSource = MXTableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func pickerImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil);
        if let image = info[UIImagePickerControllerOriginalImage]  {
            let context = AppDelegate.defalut.managerContext;
            context?.performChanges {
               _ = Photo.insert(into: context!, image: image as! UIImage);
            }
        }
    }
}

extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PhotoCell;
        let context = AppDelegate.defalut.managerContext!;
        context.performChanges {
            AppDelegate.defalut.managerContext?.delete(cell.photo!);
        }
    }
    
}

extension ViewController:MXDataProviderDelegate{
    func dataProviderDidUpdate(_ updates: [MXDataProviderUpdate<Photo>]?) {
        dataSource.processUpdates(updates)
    }
}

extension ViewController:MXDataSourceDelegate{
    func cellIdentifierForObject(_ object: Photo) -> String {
        return identifier;
    }
}
