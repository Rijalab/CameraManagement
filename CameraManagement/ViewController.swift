//
//  ViewController.swift
//  CameraManagement
//
//  Created by rajamohamed on 19/06/17.
//  Copyright © 2017 sedintechnologies. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var bitmapImagView: UIImageView!
    
var picker:UIImagePickerController?=UIImagePickerController()

    override func viewDidLoad() {

        super.viewDidLoad()
        picker?.delegate=self
        cameraBtn.addTarget(self, action: #selector(self.openCamera), for: .touchUpInside)
        galleryBtn.addTarget(self, action:#selector(self.openGallery), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func callMe(_ sender: Any) {
        openGallery()
    }

    func openGallery()
    {
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        
        picker?.allowsEditing = false
        picker?.sourceType = .photoLibrary
        picker?.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker?.modalPresentationStyle = .popover
        present(picker!, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            bitmapImagView.image = image
            let url = info[UIImagePickerControllerReferenceURL] as? URL
            self.uploadImage(image: image)
        } else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }

    func uploadImage(image : UIImage) {

        let imgData = UIImageJPEGRepresentation(image, 0.2)!

        let parameters = ["name": "rname"]

        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "fileset",fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:"mysite/upload.php")
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })

                upload.responseJSON { response in
                    print(response.result.value)
                }

            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}
