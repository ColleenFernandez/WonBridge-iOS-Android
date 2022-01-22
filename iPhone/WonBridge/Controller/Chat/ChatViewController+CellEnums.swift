//
//  ChatViewController+CellEnums.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

// MARK: - @extension height for cell type
extension MessageContentType {
    
    func chatCellHeight(model: ChatEntity) -> CGFloat {
        switch self {
        case .TEXT :
            return ChatTextCell.layoutHeight(model)
        case .IMAGE :
            return ChatImageCell.layoutHeight(model)
        case .VIDEO:
            return ChatImageCell.layoutHeight(model)
        case .SYSTEM:
            return ChatSystemCell.layoutHeight(model)
        case  .FILE:
            return 60
        case .TIME:
            return ChatTimeCell.heightForCell()
        }
    }
    
    func chatCell(tableView: UITableView, indexPath: NSIndexPath, model: ChatEntity, room: RoomEntity?, user: UserEntity, viewController: ChatViewController) -> UITableViewCell? {
        
        switch self {
            
        case .TEXT :
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ChatTextCell.identifier, forIndexPath: indexPath) as! ChatTextCell
            cell.delegate = viewController
            cell.setCellContent(model, room: room, user: user)
            return cell
            
        case .TIME:            
            let cell = tableView.dequeueReusableCellWithIdentifier(ChatTimeCell.identifier, forIndexPath: indexPath) as! ChatTimeCell
            cell.setCellContent(model)
            return cell
            
        case .IMAGE:
            let cell = tableView.dequeueReusableCellWithIdentifier(ChatImageCell.identifier, forIndexPath: indexPath) as! ChatImageCell
            cell.delegate = viewController
            cell.setCellContent(model, room: room, user: user)
            return cell
            
        case .VIDEO:
            let cell = tableView.dequeueReusableCellWithIdentifier(ChatImageCell.identifier, forIndexPath: indexPath) as! ChatImageCell
            cell.delegate = viewController
            cell.setCellContent(model, room: room, user: user)
            return cell
            
        case .SYSTEM:
            let cell = tableView.dequeueReusableCellWithIdentifier(ChatSystemCell.identifier, forIndexPath: indexPath) as! ChatSystemCell
            cell.setCellContent(model, user: user)
            return cell
            
        default:            
            return ChatBaseCell()
        }
    }
    
}

