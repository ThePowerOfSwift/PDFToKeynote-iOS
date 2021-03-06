//
//  BackgroundColorTableViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class BackgroundColorTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    var isConfigured = false
    @IBOutlet weak var colorHexCodeLabel: UILabel!
    @IBOutlet weak var colorReadableDescriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: ColorPickerDelegate?
    
    var greyscaleColors: [UIColor] = [UIColor(hexString: "FFFFFE"),
                                      UIColor(hexString: "000000"),
                                      UIColor(hexString: "929192"),
                                      UIColor(hexString: "5D5D5D"),
                                      UIColor(hexString: "D5D4D4")]
    var greyscaleColorsDescription = ["White", "Black", "Mid Gray", "Dark Gray", "Light Gray"]

    var rainbowColors: [[UIColor]] = [[UIColor(hexString: "73BDF9"),
                                       UIColor(hexString: "489EF7"),
                                       UIColor(hexString: "3274B4"),
                                       UIColor(hexString: "1E4B7B")],

                                      [UIColor(hexString: "99F9EB"),
                                       UIColor(hexString: "6BE3CF"),
                                       UIColor(hexString: "4BA59D"),
                                       UIColor(hexString: "347975")],

                                      [UIColor(hexString: "A4F669"),
                                       UIColor(hexString: "81D552"),
                                       UIColor(hexString: "54AE32"),
                                       UIColor(hexString: "2F6F1C")],

                                      [UIColor(hexString: "FEFB7E"),
                                       UIColor(hexString: "F5E359"),
                                       UIColor(hexString: "EEBE41"),
                                       UIColor(hexString: "EF9936")],

                                      [UIColor(hexString: "F09B90"),
                                       UIColor(hexString: "EB6E57"),
                                       UIColor(hexString: "DB3A26"),
                                       UIColor(hexString: "A62B19")],

                                      [UIColor(hexString: "EF92C3"),
                                       UIColor(hexString: "DD68A5"),
                                       UIColor(hexString: "BA3979"),
                                       UIColor(hexString: "8D275D")],
    ]

    var rainbowColorsDescription = ["Blue", "Cyan", "Green", "Yellow", "Red", "Magenta"]
    let rainbowModifier = ["Light", "Mid", "Dim", "Dark"]

    var selectedColorIndex: (Int, Int) = (-1, 0)

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configurateCollectionView() {
        if !isConfigured {
            let layout = JEKScrollableSectionCollectionViewLayout()
            layout.itemSize = CGSize(width: 86, height: 86)
            layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            layout.minimumInteritemSpacing = 0
            collectionView.collectionViewLayout = layout
            collectionView.delegate = self
            collectionView.dataSource = self
            isConfigured = true
            collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return greyscaleColors.count + 1
        } else if section == 1 {
            return rainbowColors.count + 1
        } else {
            return 0
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func hideTickOnEverythingExceptSelection() {
        for i in 0..<greyscaleColors.count {
            if (-1, i) != selectedColorIndex {
                if let sc = self.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? SingleColorCollectionViewCell {
                    sc.greenTickView.isHidden = true
                }
            }
        }
        for i in 0..<rainbowColors.count {
            if selectedColorIndex.0 != i {
                if let sc = self.collectionView.cellForItem(at: IndexPath(row: i, section: 1)) as? MultipleColorCollectionViewCell {
                    sc.greenTickView.isHidden = true
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && indexPath.row < greyscaleColors.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleColorCollectionViewCell", for: indexPath) as! SingleColorCollectionViewCell
            cell.delegate = self.delegate
            cell.colorView.backgroundColor = greyscaleColors[indexPath.row]
            cell.correspondingIndex = indexPath.row
            if ((-1, cell.correspondingIndex!) != selectedColorIndex) {
                cell.greenTickView.isHidden = true
            } else {
                cell.greenTickView.isHidden = false
            }
            cell.colorTappedCallback = { color, index, cell in
                self.delegate?.changeToNewColor(color: color)
                self.selectedColorIndex = (-1, index)
                cell.greenTickView.isHidden = false
                self.hideTickOnEverythingExceptSelection()
                self.colorHexCodeLabel.text = "#\(color.hexCode)"
                self.colorReadableDescriptionLabel.text = self.greyscaleColorsDescription[index]
            }

            return cell
        } else if indexPath.section == 1 && indexPath.row < rainbowColors.count  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleColorCollectionViewCell", for: indexPath) as! MultipleColorCollectionViewCell
            cell.delegate = self.delegate
            let rainbow = rainbowColors[indexPath.row]
            cell.color1Button.backgroundColor = rainbow[0]
            cell.color2Button.backgroundColor = rainbow[1]
            cell.color3Button.backgroundColor = rainbow[2]
            cell.color4Button.backgroundColor = rainbow[3]
            cell.correspondingIndex = indexPath.row
            if (selectedColorIndex.0 == indexPath.row) {
                cell.greenTickView.isHidden = false
                cell.setTickAtLocation(selectedColorIndex.1)
            } else {
                cell.greenTickView.isHidden = true
            }
            cell.colorTappedCallback = { color, index, cell in
                self.delegate?.changeToNewColor(color: color)
                self.selectedColorIndex = index
                cell.setTickAtLocation(self.selectedColorIndex.1)
                cell.greenTickView.isHidden = false
                self.hideTickOnEverythingExceptSelection()
                self.colorHexCodeLabel.text = "#\(color.altHexString())"
                self.colorReadableDescriptionLabel.text = "\(self.rainbowModifier[index.1]) \(self.rainbowColorsDescription[index.0])"
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomEntryCollectionViewCell", for: indexPath) as! CustomEntryCollectionViewCell
            cell.colorSelectionCallback = { isRainbowMode, color in
                if isRainbowMode {
                    self.rainbowColors.append([color.adjust(by: 20), color, color.adjust(by: -20), color.adjust(by: -40)])
                    self.rainbowColorsDescription.append("Custom")
                    self.selectedColorIndex = (self.rainbowColors.count - 1, 1)
                    self.hideTickOnEverythingExceptSelection()
                    self.collectionView.insertItems(at: [IndexPath(row: self.selectedColorIndex.0, section: 1)])
                } else {
                    self.greyscaleColors.append(color)
                    self.greyscaleColorsDescription.append("Custom")
                    self.selectedColorIndex = (-1, self.greyscaleColors.count - 1)
                    self.hideTickOnEverythingExceptSelection()
                    self.collectionView.insertItems(at: [IndexPath(row: self.selectedColorIndex.1, section: 0)])
                }
                self.delegate?.changeToNewColor(color: color)
                self.colorHexCodeLabel.text = "#\(color.hexCode)"
                self.colorReadableDescriptionLabel.text = isRainbowMode ? "Mid Custom" : "Custom"
            }
            cell.isRainbowMode = indexPath.section != 0
            cell.colorDelegate = self.delegate
            cell.isColorMode = true
            return cell
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
