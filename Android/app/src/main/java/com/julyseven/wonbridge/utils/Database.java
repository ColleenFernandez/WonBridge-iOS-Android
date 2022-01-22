/* Copyright 2014 Sheldon Neilson www.neilson.co.za
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.julyseven.wonbridge.utils;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.text.TextUtils;

import com.julyseven.wonbridge.Chatting.GroupChatItem;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.RoomEntity;

import java.util.ArrayList;

/* 
 * usage:  
 * DatabaseSetup.init(egActivityOrContext); 
 * DatabaseSetup.createEntry() or DatabaseSetup.getContactNames() or DatabaseSetup.getDb() 
 * DatabaseSetup.deactivate() then job done 
 */

public class Database extends SQLiteOpenHelper {

	private static Context _context = null;

	static Database instance = null;
	static SQLiteDatabase database = null;

	static final String DATABASE_NAME = "DB";
	static final int DATABASE_VERSION = 1;

	public static final String MESSAGE_TABLE = "tbl_message";

	public static final String COLUMN_MESSAGE_ID = "_id";
	public static final String COLUMN_MESSAGE_SENDER = "sender";
	public static final String COLUMN_MESSAGE_ROOMNAME = "room_name";
	public static final String COLUMN_MESSAGE_BODY = "message";
	public static final String COLUMN_MESSAGE_TYPE = "type";
	public static final String COLUMN_MESSAGE_TIME = "time";


	public static final String ROOM_TABLE = "tbl_room";

	public static final String COLUMN_ROOM_ID = "_id";
	public static final String COLUMN_ROOM_NAME = "name";
	public static final String COLUMN_ROOM_PARTICIPANTS = "participants";
	public static final String COLUMN_ROOM_RECENT_MESSAGE = "recent_message";
	public static final String COLUMN_ROOM_RECENT_TIME = "recent_time";
	public static final String COLUMN_ROOM_RECENT_COUNTER = "recent_counter";
	public static final String COLUMN_ROOM_LEAVEMEMBERS = "leave_members";


	public static final String BLOCK_TABLE = "tbl_block";

	public static final String COLUMN_BLOCK_ID = "_id";
	public static final String COLUMN_BLOCK_FRINED_ID = "friend_idx";

	public static final String FRIEND_TABLE = "tbl_friend";

	public static final String COLUMN_FRIEND_ID = "_id";
	public static final String COLUMN_FRIEND_FRINED_ID = "friend_idx";


	public static void init(Context context) {

		if (null == instance) {
			instance = new Database(context);
			_context = context;
		}
	}

	public static SQLiteDatabase getDatabase() {

		if (null == database) {
			database = instance.getWritableDatabase();
		}
		return database;
	}

	public static void deactivate() {

		if (null != database && database.isOpen()) {
			database.close();
		}
		database = null;
		instance = null;
	}

	Database(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {

		db.execSQL("CREATE TABLE IF NOT EXISTS " + MESSAGE_TABLE + " ( "
				+ COLUMN_MESSAGE_ID + " INTEGER primary key autoincrement, "
				+ COLUMN_MESSAGE_SENDER + " INTEGER NOT NULL, "
				+ COLUMN_MESSAGE_ROOMNAME + " TEXT NOT NULL, "
				+ COLUMN_MESSAGE_BODY + " TEXT NOT NULL, "
				+ COLUMN_MESSAGE_TYPE + " INTEGER NOT NULL, "
				+ COLUMN_MESSAGE_TIME + " TEXT NOT NULL)");


		db.execSQL("CREATE TABLE IF NOT EXISTS " + ROOM_TABLE + " ( "
				+ COLUMN_ROOM_ID + " INTEGER primary key autoincrement, "
				+ COLUMN_ROOM_NAME + " TEXT NOT NULL, "
				+ COLUMN_ROOM_PARTICIPANTS + " TEXT NOT NULL, "
				+ COLUMN_ROOM_RECENT_MESSAGE + " TEXT NOT NULL, "
				+ COLUMN_ROOM_RECENT_TIME + " TEXT NOT NULL, "
				+ COLUMN_ROOM_RECENT_COUNTER + " INTEGER NOT NULL, "
				+ COLUMN_ROOM_LEAVEMEMBERS + " TEXT NOT NULL)");

		db.execSQL("CREATE TABLE IF NOT EXISTS " + BLOCK_TABLE + " ( "
				+ COLUMN_BLOCK_ID + " INTEGER primary key autoincrement, "
				+ COLUMN_BLOCK_FRINED_ID + " INTEGER NOT NULL)");

		db.execSQL("CREATE TABLE IF NOT EXISTS " + FRIEND_TABLE + " ( "
				+ COLUMN_FRIEND_ID + " INTEGER primary key autoincrement, "
				+ COLUMN_FRIEND_FRINED_ID + " INTEGER NOT NULL)");
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

	}

	public static void initDatabase() {

		deleteAllRoom();
		deleteAllMessage();
		deleteAllBlocks();
		deleteAllFriends();
	}

	public static ContentValues getContentMessageValues(GroupChatItem chatItem) {

		ContentValues cv = new ContentValues();

		cv.put(COLUMN_MESSAGE_SENDER, chatItem.getSender());
		cv.put(COLUMN_MESSAGE_ROOMNAME, chatItem.getRoomName());
		cv.put(COLUMN_MESSAGE_BODY, chatItem.getMessage());
		cv.put(COLUMN_MESSAGE_TYPE, chatItem.getType().ordinal());
		cv.put(COLUMN_MESSAGE_TIME, chatItem.getTime());

		return cv;
	}

	public static long createMessage(GroupChatItem chatItem) {

		ContentValues cv = getContentMessageValues(chatItem);
		return getDatabase().insert(MESSAGE_TABLE, null, cv);
	}

	public static int deleteAllMessage() {
		return getDatabase().delete(MESSAGE_TABLE, "1", null);
	}

	public static int deleteRoomMessage(RoomEntity roomEntity) {

		return getDatabase().delete(MESSAGE_TABLE, COLUMN_MESSAGE_ROOMNAME + " = ?", new String[]{roomEntity.get_name()});
	}

	public static int deleteLeaveMessage(RoomEntity roomEntity, String name) {

		int count = getDatabase().delete(MESSAGE_TABLE, COLUMN_MESSAGE_ROOMNAME + " =? and " + COLUMN_MESSAGE_BODY + " =? ", new String[]{roomEntity.get_name(), name + "$" + Constants.KEY_LEAVEROOM_MARKER});
		return count;
	}

	public static int deleteUserMessage(RoomEntity roomEntity, int sender) {

		int count = getDatabase().delete(MESSAGE_TABLE, COLUMN_MESSAGE_ROOMNAME + " =? and " + COLUMN_MESSAGE_SENDER + " =? ", new String[]{roomEntity.get_name(), String.valueOf(sender)});
		return count;
	}


	public static ArrayList<GroupChatItem> getAllMessage() {

		ArrayList<GroupChatItem> chatItems = new ArrayList<GroupChatItem>();

		String[] columns = new String[] {
				COLUMN_MESSAGE_ID, COLUMN_MESSAGE_SENDER, COLUMN_MESSAGE_ROOMNAME, COLUMN_MESSAGE_BODY, COLUMN_MESSAGE_TYPE, COLUMN_MESSAGE_TIME };

		Cursor cursor = getDatabase().query(MESSAGE_TABLE, columns, null, null, null,
				null, null);

		if (cursor.moveToFirst()) {

			do {
				GroupChatItem chat = new GroupChatItem(cursor.getInt(1), cursor.getString(2), cursor.getString(3), cursor.getInt(4), cursor.getString(5));
				chatItems.add(chat);

			} while (cursor.moveToNext());
		}

		cursor.close();

		return chatItems;
	}

	public static ArrayList<GroupChatItem> getRecentMessage(String roomname, int count) {

		ArrayList<GroupChatItem> chatItems = new ArrayList<GroupChatItem>();

		String[] columns = new String[] {
				COLUMN_MESSAGE_ID, COLUMN_MESSAGE_SENDER, COLUMN_MESSAGE_ROOMNAME, COLUMN_MESSAGE_BODY, COLUMN_MESSAGE_TYPE, COLUMN_MESSAGE_TIME };

//		Cursor cursor = getDatabase().query(MESSAGE_TABLE, columns, COLUMN_MESSAGE_ROOMNAME + " = ?", new String[]{roomname}, null,
//				null, COLUMN_MESSAGE_ID + " DESC", String.valueOf(Constants.RECENT_MESSAGE_COUNT));

		String queryString = "SELECT * from (SELECT * from " + MESSAGE_TABLE + " where " + COLUMN_MESSAGE_ROOMNAME + " = " + "'" + roomname +
				"' ORDER BY " +  COLUMN_MESSAGE_ID + " DESC LIMIT " + String.valueOf(Constants.RECENT_MESSAGE_COUNT * count) + ") AS table1 ORDER BY " +  COLUMN_MESSAGE_ID;

		Cursor cursor = getDatabase().rawQuery(queryString, null);

		if (cursor.moveToFirst()) {

			do {
				GroupChatItem chat = new GroupChatItem(cursor.getInt(1), cursor.getString(2), cursor.getString(3), cursor.getInt(4), cursor.getString(5));
				chatItems.add(chat);

			} while (cursor.moveToNext());
		}

		cursor.close();

		return chatItems;
	}


	public static ContentValues getContentRoomValues(RoomEntity roomEntity) {

		ContentValues cv = new ContentValues();

		cv.put(COLUMN_ROOM_NAME, roomEntity.get_name());
		cv.put(COLUMN_ROOM_PARTICIPANTS, roomEntity.get_participants());
		cv.put(COLUMN_ROOM_RECENT_MESSAGE, roomEntity.get_recentContent());
		cv.put(COLUMN_ROOM_RECENT_TIME, roomEntity.get_recentTime());
		cv.put(COLUMN_ROOM_RECENT_COUNTER, roomEntity.get_recentCounter());
		cv.put(COLUMN_ROOM_LEAVEMEMBERS, roomEntity.get_leaveMembers());

		return cv;
	}

	public static long createRoom(RoomEntity roomEntity) {

		if (isExistRoom(roomEntity))
			return updateRoom(roomEntity);

		ContentValues cv = getContentRoomValues(roomEntity);

		return getDatabase().insert(ROOM_TABLE, null, cv);
	}

	public static long updateRoom(RoomEntity roomEntity) {

		ContentValues cv = getContentRoomValues(roomEntity);

		return getDatabase().update(ROOM_TABLE,
				cv, COLUMN_ROOM_NAME + "=" + "'" + roomEntity.get_name() + "'", null);
	}

	public static boolean isExistRoom(RoomEntity roomEntity) {

		String Query = "Select * from " + ROOM_TABLE + " where " + COLUMN_ROOM_NAME + " = " + "'" + roomEntity.get_name() + "'";

		Cursor cursor = getDatabase().rawQuery(Query, null);
		if(cursor.getCount() <= 0){
			cursor.close();
			return false;
		}
		cursor.close();
		return true;
	}

	public static RoomEntity getRoom(String roomname) {

		String Query = "Select * from " + ROOM_TABLE + " where " + COLUMN_ROOM_NAME + " = " + "'" + roomname + "'";

		Cursor cursor = getDatabase().rawQuery(Query, null);
		if(cursor.getCount() <= 0){
			cursor.close();
			return null;
		}

		if (cursor.moveToFirst()) {
			RoomEntity room = new RoomEntity(cursor.getString(1), cursor.getString(2), cursor.getString(3), cursor.getString(4), cursor.getInt(5), cursor.getString(6));
			cursor.close();
			return room;
		}

		cursor.close();
		return null;
	}

	public static int deleteRoom(RoomEntity roomEntity) {

		deleteRoomMessage(roomEntity);

		return getDatabase().delete(
				ROOM_TABLE,
				COLUMN_ROOM_NAME + "=" + "'" + roomEntity.get_name() + "'", null);
	}

	public static int deleteAllRoom() {

		return getDatabase().delete(ROOM_TABLE, "1", null);
	}

	public static ArrayList<RoomEntity> getAllRoom() {

		ArrayList<RoomEntity> roomEntities = new ArrayList<RoomEntity>();

		String[] columns = new String[] {
				COLUMN_ROOM_ID, COLUMN_ROOM_NAME, COLUMN_ROOM_PARTICIPANTS, COLUMN_ROOM_RECENT_MESSAGE,
				COLUMN_ROOM_RECENT_TIME, COLUMN_ROOM_RECENT_COUNTER, COLUMN_ROOM_LEAVEMEMBERS };

		Cursor cursor = getDatabase().query(ROOM_TABLE, columns, null, null, null,
				null, null);

		if (cursor.moveToFirst()) {

			do {
				RoomEntity room = new RoomEntity(cursor.getString(1), cursor.getString(2), cursor.getString(3), cursor.getString(4), cursor.getInt(5), cursor.getString(6));
				roomEntities.add(room);

			} while (cursor.moveToNext());
		}

		cursor.close();

		return roomEntities;
	}


	// block tatble

	public static ContentValues getContentBlockValues(int idx) {

		ContentValues cv = new ContentValues();
		cv.put(COLUMN_BLOCK_FRINED_ID, String.valueOf(idx));

		return cv;
	}

	public static long createBlock(int idx) {

		ContentValues cv = getContentBlockValues(idx);

		return getDatabase().insert(BLOCK_TABLE, null, cv);
	}

	public static int deleteBlock(int idx) {

		return getDatabase().delete(
				BLOCK_TABLE,
				COLUMN_BLOCK_FRINED_ID + "=" + "'" + String.valueOf(idx) + "'", null);
	}

	public static int deleteAllBlocks() {

		return getDatabase().delete(BLOCK_TABLE, "1", null);
	}

	public static ArrayList<Integer> getAllBlocks() {

		ArrayList<Integer> idxs = new ArrayList<Integer>();

		String[] columns = new String[] {
				COLUMN_BLOCK_ID, COLUMN_BLOCK_FRINED_ID };

		Cursor cursor = getDatabase().query(BLOCK_TABLE, columns, null, null, null,
				null, null);

		if (cursor.moveToFirst()) {

			do {
				idxs.add(Integer.valueOf(cursor.getInt(1)));

			} while (cursor.moveToNext());
		}

		cursor.close();

		return idxs;
	}

	public static boolean isBlocked(int idx) {

		return getAllBlocks().contains(Integer.valueOf(idx));
	}

	// friend tatble

	public static ContentValues getContentFriendValues(int idx) {

		ContentValues cv = new ContentValues();
		cv.put(COLUMN_FRIEND_FRINED_ID, String.valueOf(idx));

		return cv;
	}

	public static long createFriend(int idx) {

		ContentValues cv = getContentFriendValues(idx);

		return getDatabase().insert(FRIEND_TABLE, null, cv);
	}

	public static int deleteFriend(int idx) {

		return getDatabase().delete(
				FRIEND_TABLE,
				COLUMN_FRIEND_FRINED_ID + "=" + "'" + String.valueOf(idx) + "'", null);
	}

	public static int deleteAllFriends() {

		return getDatabase().delete(FRIEND_TABLE, "1", null);
	}

	public static ArrayList<Integer> getAllFriends() {

		ArrayList<Integer> idxs = new ArrayList<Integer>();

		String[] columns = new String[] {
				COLUMN_FRIEND_ID, COLUMN_FRIEND_FRINED_ID };

		Cursor cursor = getDatabase().query(FRIEND_TABLE, columns, null, null, null,
				null, null);

		if (cursor.moveToFirst()) {

			do {
				idxs.add(Integer.valueOf(cursor.getInt(1)));

			} while (cursor.moveToNext());
		}

		cursor.close();

		return idxs;
	}

	public static boolean isFriend(int idx) {

		return getAllFriends().contains(Integer.valueOf(idx));
	}
}