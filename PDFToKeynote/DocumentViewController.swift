//
//  DocumentViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/7/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import PDFKit
import Zip
import FloatingPanel

class DocumentViewController: UIViewController, FloatingPanelControllerDelegate {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var natigationBarItem: UINavigationItem!
    @IBOutlet weak var navigationDoneButton: UIBarButtonItem!
    var document: UIDocument?
    var floatingController: FloatingPanelController?
    weak var configurationVC: ConfigurationViewController?

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        print("Size class: (V: \(newCollection.verticalSizeClass.rawValue), H: \(newCollection.horizontalSizeClass.rawValue))")
        if newCollection.verticalSizeClass == .regular && newCollection.horizontalSizeClass == .regular {
            return ConverterFloatingLandscapePanelLayout()
        } else {
            return ConverterFloatingPanelLayout()
        }
//        return (newCollection.verticalSizeClass == .regular) ? ConverterFloatingPanelLayout() : ConverterFloatingLandscapePanelLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        if (traitCollection.horizontalSizeClass == .compact) {
//        } else {
//            floatingController?.removePanelFromParent(animated: false)
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if floatingController == nil {
            floatingController = FloatingPanelController()
            floatingController?.surfaceView.backgroundColor = .clear
            floatingController?.surfaceView.cornerRadius = 9.0
            floatingController?.surfaceView.shadowHidden = false
            floatingController?.delegate = self

            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            configurationVC = storyBoard.instantiateViewController(withIdentifier: "ConfigurationViewController") as? ConfigurationViewController
            configurationVC?.enableDisableStateChanged = { state in
                self.navigationDoneButton.isEnabled = state
            }
            floatingController?.set(contentViewController: configurationVC)

            // fpc.track(scrollView: contentVC.tableView)
        }
        floatingController?.addPanel(toParent: self)

        document?.open(completionHandler: { (success) in
            if success {
                self.natigationBarItem.title = self.document?.fileURL.lastPathComponent.stripFileExtension()
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
                self.pdfView.backgroundColor = UIColor.gray
                self.pdfView.autoScales = true
                self.configurationVC?.pdf = self.pdfView.document
                self.configurationVC?.document = self.document
            } else {
                print("Failed to load PDF document")
            }
        })
    }

    override func viewDidLoad() {
    }

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
