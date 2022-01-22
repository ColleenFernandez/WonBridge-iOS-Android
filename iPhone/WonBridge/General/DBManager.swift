//
//  DBManager.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

let MAX_LOAD_CNT = 20

class DBManager {
    
    let _dbName = "wonbridge.db"
    var dbFilePath = ""
    
    static var sharedInstance: DBManager? = nil
    class func getSharedInstance() -> DBManager {
        
        if (sharedInstance == nil) {
            sharedInstance = DBManager()
        }
        
        return sharedInstance!
    }    
    
    init () {
        
        //
        // initialize db
        //
        let fileManager = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir: NSString = dirPaths[0]
        dbFilePath = docsDir.stringByAppendingPathComponent(_dbName)
        
        if !fileManager.fileExistsAtPath(dbFilePath as String) {
            
            let localDB = FMDatabase(path: dbFilePath as String)            
            if localDB == nil {
                print("Error: \(localDB.lastErrorMessage())")
            }
            
            if (localDB.open()) {
                
                var sql_stmt = "CREATE TABLE IF NOT EXISTS ROOMTABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, PARTICIPANTS TEXT, RECENTCONTENT TEXT, RECENTTIME TEXT, RECENTCOUNTER INTEGER, LEAVEMEMBERS TEXT);"
                sql_stmt = sql_stmt + "CREATE TABLE IF NOT EXISTS CHATTABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, ROOMNAME TEXT, MESSAGE TEXT, SENDER INTEGER, DATE TEXT,  CURRENT INTEGER);"
                
                if !localDB.executeStatements(sql_stmt) {
                    print("Error: \(localDB.lastErrorMessage())")
                }
                
                localDB.close()
                
            } else {
                print(print("Error: \(localDB.lastErrorMessage())"))
            }
        }
    }
    
    // save room
    // check if the room exits on local db
    // if exists then will update room parameters with setting parameters
    func createRoom(room: RoomEntity) {
        
        let w_name = room._name
        let w_participants = room._participants
        let w_recentContent = room._recentContent
        let w_recentTime = room._recentTime
        let w_recentCount = room._recentCount
        let w_leaveMembers = room._leaveMembers
        
        let w_db = FMDatabase(path: dbFilePath)
        if w_db.open() {
            
            print("create room: \(w_db.executeUpdate("INSERT INTO ROOMTABLE(NAME, PARTICIPANTS, RECENTCONTENT, RECENTTIME, RECENTCOUNTER, LEAVEMEMBERS) VALUES(?, ?, ?, ?, ?, ?);", withArgumentsInArray: [w_name, w_participants, w_recentContent, w_recentTime, w_recentCount, w_leaveMembers]))")
        }
        w_db.close()
    }
    
    func updateRoom(room: RoomEntity) {
        
        let w_name = room._name
        let w_participant_name = room._participants
        let w_recent_message = room._recentContent
        let w_recent_time = room._recentTime
        let w_recent_counter = room._recentCount
        let w_leaveMembers = room._leaveMembers
        
        let w_db = FMDatabase(path: dbFilePath)
        if w_db.open() {
            
            w_db.executeUpdate("UPDATE ROOMTABLE SET PARTICIPANTS = ?, RECENTCONTENT = ?, RECENTTIME = ?, RECENTCOUNTER = ?, LEAVEMEMBERS = ? WHERE NAME = ?;", withArgumentsInArray: [w_participant_name, w_recent_message, w_recent_time, w_recent_counter, w_leaveMembers, w_name])
        }
        w_db.close()
    }
    
    func removeRoom(name: String) {
        
        let w_db = FMDatabase(path: dbFilePath)
        
        if w_db.open() {
            
            w_db.executeUpdate("DELETE FROM ROOMTABLE WHERE NAME = ?;", withArgumentsInArray: [name])
            w_db.executeUpdate("DELETE FROM CHATTABLE WHERE ROOMNAME = ?;", withArgumentsInArray: [name])
        }
        w_db.close()
    }
    
    func deleteUserChat(roomName: String, sender: Int) {
        
        let w_db = FMDatabase(path: dbFilePath)
        if w_db.open() {
            
            w_db.executeUpdate("DELETE FROM CHATTABLE WHERE ROOMNAME = ? AND SENDER = ?;", withArgumentsInArray: [roomName, sender])
        }
        
        w_db.close()
    }
    
    func loadRoom() -> [RoomEntity] {
        
        var w_arrRooms = [RoomEntity]()
        
        let w_db = FMDatabase(path: dbFilePath)
        
        if w_db.open() {
            
            if let w_rs = w_db.executeQuery("SELECT * FROM ROOMTABLE", withArgumentsInArray: nil) {
                
                while w_rs.next() {
                    
                    let w_name = w_rs.stringForColumn("NAME")                    
                    let w_participantsName = w_rs.stringForColumn("PARTICIPANTS")
                    let w_recentContent = w_rs.stringForColumn("RECENTCONTENT")
                    let w_recentDate = w_rs.stringForColumn("RECENTTIME")
                    let w_recentCount = Int(w_rs.intForColumn("RECENTCOUNTER"))
                    let w_leaveMembers = w_rs.stringForColumn("LEAVEMEMBERS")
                    
                    w_arrRooms.append(RoomEntity(name: w_name, participants: w_participantsName, leaveMembers: w_leaveMembers, recentContent: w_recentContent, recentTime: w_recentDate, recentCount: w_recentCount))
                }
            }
            
            w_db.close()
        }
        
        return w_arrRooms
    }
    
    func addChat(item: ChatEntity, isCurrent: Int) {
        
        let roomName = item._roomName
        let sender = item._chatSendId
        let message = item.toMessage()
        let datetime = item._timestamp
        
        // if isCurrent is 1, the message will not be loaded.
        saveChat(roomName, message: message, sender: sender, datetime: datetime, isCurrent: isCurrent)
    }
    
    func saveChat(roomName: String, message: String, sender: Int, datetime: String, isCurrent: Int) {
        
        let w_db = FMDatabase(path: dbFilePath)
        if w_db.open() {
            
            if let w_rs = w_db.executeQuery("SELECT * FROM CHATTABLE WHERE MESSAGE = ? AND DATE = ?;", withArgumentsInArray: [message, datetime]) {
                
                if w_rs.next() {
                    
                    print("item is already exist")
                } else {
                    // update
                    w_db.executeUpdate("INSERT INTO CHATTABLE(ROOMNAME, MESSAGE, SENDER, DATE, CURRENT) VALUES(?, ?, ?, ?, ?);", withArgumentsInArray: [roomName, message, sender, datetime, isCurrent])
                }
            }
        }
        w_db.close()
    }
    
    func loadMessage(roomName: String, pageIndex: Int) -> [ChatEntity] {
        
        let w_db = FMDatabase(path: dbFilePath)
        
        var results: [ChatEntity] = []
        var recentList: [ChatEntity] = []
        
        if w_db.open() {
            
            if let w_rs = w_db.executeQuery("SELECT * FROM CHATTABLE WHERE ROOMNAME = ? AND CURRENT = ? ORDER BY ID DESC LIMIT ?;", withArgumentsInArray: [roomName, 0, MAX_LOAD_CNT*pageIndex]) {
                
                while w_rs.next() {
                    
                    let msg = w_rs.stringForColumn("MESSAGE")
                    let sender = w_rs.stringForColumn("SENDER")
                    
                    let loadPacket = ChatEntity(message: msg, sender: sender, isLocalTime: true)
                    results.append(loadPacket)
                }
                
                if (results.count > MAX_LOAD_CNT*(pageIndex-1)) {
                    for index in ((MAX_LOAD_CNT * (pageIndex-1))...(results.count - 1)).reverse() {
                        
                        recentList.append(results[index])
                    }
                }
            }
            
            w_db.close()
        }
        
        return recentList
    }
    
    // called when user leave the room, update all current messages current value of chatting room that has the value current (1) to current (0)
    // current = 1: current messages of chatting room - this will be not loaded when an user load earlier message from database
    // current = 0: old messages of chatting room - this will be loaded
    func updateChatNoCurrent(roomName: String) {
        
        let w_db = FMDatabase(path: dbFilePath)
        if w_db.open() {
            w_db.executeUpdate("UPDATE CHATTABLE SET CURRENT = ? WHERE CURRENT = ? AND ROOMNAME = ?;", withArgumentsInArray: [0, 1, roomName])
        }
        w_db.close()
    }

    // update all chatting room message status 
    // current will be changed from 1 to 0
    func updateChatNoCurrent() {
        
        let w_db = FMDatabase(path: dbFilePath)
        if w_db.open() {
            w_db.executeUpdate("UPDATE CHATTABLE SET CURRENT = ? WHERE CURRENT = ?;", withArgumentsInArray: [0, 1])
        }
        w_db.close()
    }
    
    func clearDB() {
        
        let w_db = FMDatabase(path: dbFilePath)
        
        if w_db.open() {
            
            let _ = w_db.executeUpdate("DELETE FROM ROOMTABLE;", withArgumentsInArray: nil)
            
//            print("clear db: \(result1)")
            
            let _ = w_db.executeUpdate("DELETE FROM CHATTABLE;", withArgumentsInArray: nil)
            
//            print("clear db: \(result2)")
        }
        
        w_db.close()
    }
}
