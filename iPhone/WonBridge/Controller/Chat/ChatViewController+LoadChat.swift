//
//  ChatViewController+LoadChat.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

// load chat from local database.
extension ChatViewController {
    
    func loadOnlineMessage(isRefresh: Bool) {
        
        if isRefresh {
            refreshCount = 1
        } else {
            refreshCount += 1
        }
        
        WebService.loadOnlineMessage(_user!._idx, pageIndex: refreshCount) { (status, contents) in
            
            if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
            }
            
            if (status) {
                
                var arrChatList = [ChatEntity]()
                
                for content in contents! {
                    let fullMsg = self.getRoomInfoString() + content.1
                    let chatItem = content.0 == 0 ? ChatEntity(message: fullMsg, sender: "\(self._user!._idx)", imageModel: nil) : ChatEntity(message: fullMsg, sender: "\(0)", imageModel: nil)
                    arrChatList.append(chatItem)
                }
                
                if arrChatList.count > 0 {
                    
                    var loadedChat = [ChatEntity]()
                    for chatItem in arrChatList {
                        loadedChat.insert(chatItem, atIndex: 0)
                    }
                    
                    if isRefresh {
                        self.firstFetchOnlineMsgList(loadedChat)
                    } else {
                        self.pullLoadMoreOnlineMsg(loadedChat)
                    }
                    
                } else {
                    self.refreshCount -= 1
                }
                
            } else {
                self.refreshCount -= 1
            }
        }
    }
    
    func firstFetchOnlineMsgList(list: [ChatEntity]) {
        
        var indexPaths = [NSIndexPath]()

        for addChat in list {
            if addChat._date != self.lastReceivedDate {
                // update received date
                lastReceivedDate = addChat._date
                
                // add date string to chat list
                dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
                
                let revDate = dateFormatter.dateFromString(addChat._timestamp)
                dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                self.itemDataSource.append(ChatEntity(timestamp: dateFormatter.stringFromDate(revDate!)))
                
                indexPaths.insert(NSIndexPath(forRow: itemDataSource.count - 1, inSection: 0), atIndex: 0)
            }
            self.itemDataSource.append(addChat)
            
            indexPaths.insert(NSIndexPath(forRow: itemDataSource.count - 1, inSection: 0), atIndex: 0)
        }

        self.listTableView.insertRowsAtBottom(indexPaths)
    }
    
    func pullLoadMoreOnlineMsg(list: [ChatEntity]) {
        
        self.isEndRefreshing = false
        self.isReloading = true
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            
            sleep(1)
            var startIndex = 0
            var receivedDate = self.itemDataSource.get(1)._date
            if receivedDate == list.get(0)._date {
                startIndex = 1
            }
            
            var addChatList = [ChatEntity]()
            for addChat in list {
                if addChat._date != receivedDate {
                    // update received date
                    receivedDate = addChat._date
                    
                    // add date string to chat list
                    self.dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
                    
                    let revDate = self.dateFormatter.dateFromString(addChat._timestamp)
                    self.dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                    addChatList.insert(ChatEntity(timestamp: self.dateFormatter.stringFromDate(revDate!)), atIndex: addChatList.count)
                }
                addChatList.insert(addChat, atIndex: addChatList.count)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.itemDataSource.insertContentsOf(addChatList, at: startIndex)
                self.refreshControl.endRefreshing()
                self.updateTableViewNewRowCount(addChatList.count)
                self.isEndRefreshing = true
            })
        })
    }
    
    func firstFetchMessageList(roomName: String) {
        guard let list = fetchData(roomName, pageIndex: self.refreshCount) else { return }
        
        var addChatList = [ChatEntity]()
        for addChat in list {
            if addChat._date != self.lastReceivedDate {
                // update received date
                lastReceivedDate = addChat._date

                // add date string to chat list
                dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"

                let revDate = dateFormatter.dateFromString(addChat._timestamp)
                dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                addChatList.insert(ChatEntity(timestamp: dateFormatter.stringFromDate(revDate!)), atIndex: addChatList.count)
            }
            addChatList.insert(addChat, atIndex: addChatList.count)
        }
        
        self.itemDataSource.insertContentsOf(addChatList, at: 0)
        self.listTableView.reloadData({ [unowned self] _ in
            self.isReloading = false
        })
        
        self.listTableView.setContentOffset(CGPointMake(0, CGFloat.max), animated: true)
    }
    
    func pullToLoadMore() {
        self.isEndRefreshing = false
        self.isReloading = true
        
        self.refreshCount += 1
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            guard let list = self.fetchData(self.chatRoom!._name, pageIndex: self.refreshCount) else  {
                self.refreshControl.endRefreshing()
                self.isReloading = false
                self.refreshCount -= 1
                return
            }
            
            sleep(1)
            var startIndex = 0
            var receivedDate = self.itemDataSource.get(1)._date
            if receivedDate == list.get(0)._date {
                startIndex = 1
            }
            
            var addChatList = [ChatEntity]()
            for addChat in list {
                if addChat._date != receivedDate {
                    // update received date
                    receivedDate = addChat._date
                    
                    // add date string to chat list
                    self.dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
                    
                    let revDate = self.dateFormatter.dateFromString(addChat._timestamp)
                    self.dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                    addChatList.insert(ChatEntity(timestamp: self.dateFormatter.stringFromDate(revDate!)), atIndex: addChatList.count)
                }
                addChatList.insert(addChat, atIndex: addChatList.count)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.itemDataSource.insertContentsOf(addChatList, at: startIndex)
                self.refreshControl.endRefreshing()
                self.updateTableViewNewRowCount(addChatList.count)
                self.isEndRefreshing = true
            })
        })
    }
    
    func fetchData(roomName: String, pageIndex: Int) -> [ChatEntity]? {
        let dbList = DBManager.getSharedInstance().loadMessage(roomName, pageIndex: pageIndex)
        
        guard dbList.count > 0 else  { return nil }
        
        var list = [ChatEntity]()
        for chat in dbList {
           list.insert(chat, atIndex: list.count)
        }
        return dbList
    }
    
    func updateTableViewNewRowCount(count: Int) {
        
        var contentOffSet = self.listTableView.contentOffset
        
        UIView.setAnimationsEnabled(false)
        self.listTableView.beginUpdates()
        
        var heightForNewRows: CGFloat = 0
        var indexPaths = [NSIndexPath]()
        
        for index  in 0 ..< count {
            
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            indexPaths.append(indexPath)
            
            heightForNewRows += self.tableView(self.listTableView, heightForRowAtIndexPath: indexPath)
        }
        
        contentOffSet.y += heightForNewRows
        
        self.listTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
        self.listTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        self.listTableView.setContentOffset(contentOffSet, animated: false)
    }
    
    func removeTableViewNewRowCount(indexPaths: [NSIndexPath]) {
        var contentOffSet = self.listTableView.contentOffset
        
        UIView.setAnimationsEnabled(false)
        self.listTableView.beginUpdates()
        
        var heightForNewRows: CGFloat = 0
        
        for indexPath  in indexPaths {

            heightForNewRows += self.tableView(self.listTableView, heightForRowAtIndexPath: indexPath)
        }
        
        contentOffSet.y -= heightForNewRows
        
        self.listTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
        self.listTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        self.listTableView.setContentOffset(contentOffSet, animated: false)
    }
    
}




