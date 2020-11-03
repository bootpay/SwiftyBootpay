//
//  CardView.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 13/10/2020.
//

import UIKit

class CardViewCell: ScalingCarouselCell {
    var cardName: UILabel!
    var cardNo: UILabel!
    var cardChip: UIImageView!
    var cardPlus: UIImageView!
    var type = 0 //0: 기존 카드, 1: 신규카드, 2: 다른 결제수단
    var btnClick: UIButton!
    var cardEtc: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainView = UIView(frame: contentView.bounds)
        contentView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            mainView.heightAnchor.constraint(equalToConstant: contentView.frame.width * 0.75)
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
        mainView.layer.borderColor = UIColor.gray.cgColor
        
         

        cardName = UILabel()
        cardName.font =  UIFont.boldSystemFont(ofSize: 15.0)
        mainView.addSubview(cardName)

        cardNo = UILabel()
        cardNo.font =  UIFont.boldSystemFont(ofSize: 15.0)
        cardNo.textAlignment = .right
        mainView.addSubview(cardNo)
        
        cardChip = UIImageView()
        cardChip.image = UIImage.fromBundle("card_chip")
        cardChip.contentMode = .scaleAspectFit
        mainView.addSubview(cardChip)
        
        cardPlus = UIImageView()
        cardPlus.image = UIImage.fromBundle("plus")
        cardPlus.alpha = 0.8
        cardPlus.contentMode = .scaleAspectFit
        mainView.addSubview(cardPlus)
        
        cardEtc = UILabel()
        cardEtc.textColor = .white
        cardEtc.font =  UIFont.boldSystemFont(ofSize: 20.0)
        cardEtc.textAlignment = .center
        cardEtc.text = "다른 결제수단"
        mainView.addSubview(cardEtc)
        
        btnClick = UIButton()
//        mainView.addSubview(btnClick)
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(data: CardInfo?) {
        
        if let data = data {
            let colors = CardCode.getColor(code: data.card_code)
            
            if data.card_type == 0 {
                mainView.backgroundColor = colors[0]
                cardName.text = data.card_name
                cardName.textColor = colors[1]
                cardNo.text = data.card_no
                cardNo.textColor = colors[1]
            } else if data.card_type == 1 {
                mainView.backgroundColor = .white
            } else if data.card_type == 2 {
                mainView.backgroundColor = UIColor.init(red: 76.0 / 255, green: 54.0 / 255, blue: 226.0 / 255, alpha: 1.0)
            }
            
            
            cardName.snp.makeConstraints{ (make) -> Void in
                make.left.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(10)
                make.width.equalTo(100)
                make.height.equalTo(20)
            }
            
            cardNo.snp.makeConstraints{ (make) -> Void in
                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-15)
                make.height.equalTo(20)
            }
            
            cardChip.snp.makeConstraints{(make) -> Void in
                make.left.equalTo(cardName)
                make.top.equalTo(cardName).offset(30)
                make.width.equalTo(35)
                make.height.equalTo(25)
            }
            
            cardPlus.snp.makeConstraints{(make) -> Void in
                make.centerX.centerY.equalToSuperview()
                make.width.height.equalTo(50)
            }
            
            cardEtc.snp.makeConstraints{(make) -> Void in
                make.centerX.centerY.equalToSuperview()
                make.width.height.equalToSuperview()
            }
            
            btnClick.tag = data.tag
//            btnClick.snp.makeConstraints{(make) -> Void in
//                make.centerX.centerY.equalToSuperview()
//                make.width.equalTo(mainView.frame.width/3)
//                make.height.equalTo(mainView.frame.height/3)
//            }
            
            
            mainView.layer.borderWidth = data.card_type == 0 ? 0.5 : 1
            cardName.isHidden = data.card_type != 0
            cardNo.isHidden = data.card_type != 0
            cardChip.isHidden = data.card_type != 0
            cardPlus.isHidden = data.card_type != 1
            cardEtc.isHidden = data.card_type != 2
        }
        
    }
    
}
