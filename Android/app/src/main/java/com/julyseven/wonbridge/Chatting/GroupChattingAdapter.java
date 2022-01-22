package com.julyseven.wonbridge.Chatting;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.AnimationDrawable;
import android.os.AsyncTask;
import android.support.v4.util.LruCache;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.utils.BitmapUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import de.hdodenhof.circleimageview.CircleImageView;

/**
 * Created by HGS on 12/14/2015.
 */
public class GroupChattingAdapter extends BaseAdapter {

    private static final int TYPE_CHAT = 0;
    private static final int TYPE_DATE = 1;

    public ArrayList<Object> _chatList = new ArrayList<>();

    private GroupChattingActivity _context;

    private UserEntity _user = null;

    private LruCache<String, Bitmap> mMemoryCache;

    private boolean _firstNormal = false;

    private Date _lastDate = null;

    public GroupChattingAdapter(Context context){

        super();

        this._context = (GroupChattingActivity) context;

        _user = Commons.g_user;

        final int maxMemory = (int) (Runtime.getRuntime().maxMemory() / 1024);

        // Use 1/8th of the available memory for this memory cache.
        final int cacheSize = maxMemory / 8;

        mMemoryCache = new LruCache<String, Bitmap>(cacheSize) {
            @Override
            protected int sizeOf(String key, Bitmap bitmap) {
                // The cache size will be measured in kilobytes rather than
                // number of items.
                return bitmap.getByteCount() / 1024;
            }
        };

    }



    public void deleteUserMessage(ArrayList<String> idArray) {

        ArrayList<Object> copy = new ArrayList<>();
        copy.addAll(_chatList);

        for (int i = 0; i < copy.size(); i++) {

            Object item = copy.get(i);

            if (item instanceof GroupChatItem) {
                GroupChatItem chatItem = (GroupChatItem) item;

                if (idArray.contains(String.valueOf(chatItem.getSender()))) {
                    if (_chatList.contains(chatItem))
                        _chatList.remove(item);
                }

            }
        }

        notifyDataSetChanged();

    }


    public void clearAll() {
        _chatList.clear();
        _lastDate = null;
    }

    @Override
    public int getCount(){

          return _chatList.size();
    }

    @Override
    public Object getItem(int position){

        return _chatList.get(position);
    }

    @Override
    public long getItemId(int position){

        return position;
    }

    @Override
    public int getViewTypeCount() {
        return 2;
    }

    @Override
    public int getItemViewType(int position) {

        if (getItem(position) instanceof GroupChatItem)
            return TYPE_CHAT;

        return TYPE_DATE;
    }

    @Override
    public boolean isEnabled(int position) {
        return (getItemViewType(position) == TYPE_CHAT);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){

        int type = getItemViewType(position);

        switch (type) {

            case TYPE_DATE: {

                DateHolder dateHolder;

                    if (convertView == null){

                    dateHolder = new DateHolder();

                    LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                    convertView = inflater.inflate(R.layout.chatting_header, null);

                    dateHolder.txvDate = (TextView)convertView.findViewById(R.id.txv_date);
                    convertView.setTag(dateHolder);

                } else {
                    dateHolder = (DateHolder)convertView.getTag();
                }

                String date = (String) _chatList.get(position);
                dateHolder.txvDate.setText(date);

                return convertView;

            }

            case TYPE_CHAT:
            default: {

                ChattingHolder chattingHolder;

                if (convertView == null){

                    chattingHolder = new ChattingHolder();

                    LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                    convertView = inflater.inflate(R.layout.item_chatting, null);

                    chattingHolder.imvFriendPhoto = (CircleImageView)convertView.findViewById(R.id.imv_friendPhoto);
                    chattingHolder.txvFriendName = (TextView)convertView.findViewById(R.id.txv_friendName);
                    chattingHolder.txvFriendMessage = (TextView)convertView.findViewById(R.id.txv_message1);
                    chattingHolder.txvTime1 = (TextView) convertView.findViewById(R.id.txv_time1);
                    chattingHolder.imvFriendImage = (ImageView) convertView.findViewById(R.id.imv_imgmsg1);
                    chattingHolder.fltVideoPreview1 = (FrameLayout) convertView.findViewById(R.id.flt_video1);
                    chattingHolder.imvVideoPreview1 = (ImageView) convertView.findViewById(R.id.imv_video1);
                    chattingHolder.imvVideoMarker1 = (ImageView) convertView.findViewById(R.id.imv_videoMark1);
                    chattingHolder.imvVideoProgress1 = (ImageView) convertView.findViewById(R.id.imv_videoprogress1);

                    chattingHolder.imvMyPhoto = (CircleImageView) convertView.findViewById(R.id.imv_myPhoto);
                    chattingHolder.txvMyMessage = (TextView) convertView.findViewById(R.id.txv_message2);
                    chattingHolder.txvTime2 = (TextView) convertView.findViewById(R.id.txv_time2);
                    chattingHolder.imvMyImage = (ImageView) convertView.findViewById(R.id.imv_imgmsg2);
                    chattingHolder.imvImageProgress2 = (ImageView) convertView.findViewById(R.id.imv_imgprogress2);
                    chattingHolder.fltVideoPreview2 = (FrameLayout) convertView.findViewById(R.id.flt_video2);
                    chattingHolder.imvVideoPreview2 = (ImageView) convertView.findViewById(R.id.imv_video2);
                    chattingHolder.imvVideoProgress2 = (ImageView) convertView.findViewById(R.id.imv_videoprogress2);
                    chattingHolder.imvVideoMarker2 = (ImageView) convertView.findViewById(R.id.imv_videoMark2);

                    chattingHolder.txvStatus = (TextView) convertView.findViewById(R.id.txv_status);

                    convertView.setTag(chattingHolder);

                } else {
                    chattingHolder = (ChattingHolder)convertView.getTag();
                }

                final GroupChatItem chatItem = (GroupChatItem) _chatList.get(position);

                chattingHolder.imvFriendPhoto.setVisibility(View.GONE);
                chattingHolder.txvFriendName.setVisibility(View.GONE);
                chattingHolder.txvFriendMessage.setVisibility(View.GONE);
                chattingHolder.txvTime1.setVisibility(View.GONE);
                chattingHolder.imvFriendImage.setVisibility(View.GONE);
                chattingHolder.imvFriendImage.setImageBitmap(null);
                chattingHolder.fltVideoPreview1.setVisibility(View.GONE);

                chattingHolder.imvMyPhoto.setVisibility(View.GONE);
                chattingHolder.txvMyMessage.setVisibility(View.GONE);
                chattingHolder.txvTime2.setVisibility(View.GONE);
                chattingHolder.imvMyImage.setVisibility(View.GONE);
                chattingHolder.imvMyImage.setImageBitmap(null);
                chattingHolder.imvImageProgress2.setVisibility(View.GONE);
                chattingHolder.fltVideoPreview2.setVisibility(View.GONE);

                chattingHolder.txvStatus.setVisibility(View.GONE);

//                chattingHolder.txvMyMessage.setBackgroundResource(R.drawable.bg_balloon_b);
//                chattingHolder.txvFriendMessage.setBackgroundResource(R.drawable.bg_balloon_g);

                // online chatting with admin
                if (chatItem.getSender() == 0) {

                    chattingHolder.imvFriendPhoto.setVisibility(View.VISIBLE);
                    //chattingHolder.txvFriendName.setVisibility(View.VISIBLE);
                    chattingHolder.txvTime1.setVisibility(View.VISIBLE);

                    chattingHolder.imvFriendPhoto.setImageResource(R.mipmap.ic_launcher);
                    chattingHolder.txvFriendName.setText(Constants.WONBRIDGE);
                    chattingHolder.txvTime1.setText(chatItem.getDisplayTime());

                    // text
                    if (chatItem.getType() == GroupChatItem.ChatType.TEXT) {

                        chattingHolder.txvFriendMessage.setVisibility(View.VISIBLE);

                        // emoji
                        if (chatItem.getMessage().startsWith(EmojiFragment.EMOJI_PREFIX) &&
                                chatItem.getMessage().endsWith(EmojiFragment.EMOJI_SUFFIX)) {

                            int emojiIdx = Integer.parseInt(chatItem.getMessage().substring(EmojiFragment.EMOJI_PREFIX.length(), chatItem.getMessage().indexOf(EmojiFragment.EMOJI_SUFFIX)));
                            chattingHolder.txvFriendMessage.setBackgroundResource(EmojiFragment.emoji_ids[emojiIdx]);
                            chattingHolder.txvFriendMessage.setText("");

                        } else {

                            chattingHolder.txvFriendMessage.setText(chatItem.getMessage());
                            chattingHolder.txvFriendMessage.setBackgroundResource(R.drawable.bg_balloon_g);
                            chattingHolder.txvFriendMessage.setPadding(Commons.GetPixelValueFromDp(_context, 16), Commons.GetPixelValueFromDp(_context, 8), Commons.GetPixelValueFromDp(_context, 8), Commons.GetPixelValueFromDp(_context, 8));

                        }

                    }
                    // image
                    else if (chatItem.getType() == GroupChatItem.ChatType.IMAGE) {

                        chattingHolder.imvFriendImage.setVisibility(View.VISIBLE);

                        int width = chatItem.getImageWidth();
                        int height = chatItem.getImageHeight();

                        if (width == 0)
                            width = BitmapUtils.IMAGE_MAX_SIZE;

                        if (height == 0)
                            height = BitmapUtils.IMAGE_MAX_SIZE;

                        width = width * BitmapUtils.IMAGE_MAX_SIZE / height;
                        height = BitmapUtils.IMAGE_MAX_SIZE;

                        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(width, height);
                        chattingHolder.imvFriendImage.setLayoutParams(layoutParams);

                        Glide.with(_context).load(chatItem.getFileUrl()).into(chattingHolder.imvFriendImage);

                    }

                }
                // my message
                else if (chatItem.getSender() == _user.get_idx()) {

                    // system
                    if (chatItem.getType() == GroupChatItem.ChatType.SYSTEM) {

                        chattingHolder.txvStatus.setVisibility(View.VISIBLE);
                        chattingHolder.txvStatus.setTextColor(0xff919191);

                        if (chatItem.getMessage().contains(Constants.KEY_GROUPNOTI_MARKER)) {

                            chattingHolder.txvStatus.setTextColor(0xff5f99fb);
                            chattingHolder.txvStatus.setText(chatItem.getMessage());

                        } else if (chatItem.getMessage().contains(Constants.KEY_DELEGATE_MARKER)) {

                            int dolPos = chatItem.getMessage().lastIndexOf("$");
                            String roomname = chatItem.getMessage().substring(0, dolPos);
                            dolPos = roomname.lastIndexOf("$");
                            String name = roomname.substring(0, dolPos);
                            chattingHolder.txvStatus.setText(name + _context.getString(R.string.become_groupowner));

                        } else if (chatItem.getMessage().contains(Constants.KEY_INVITE_MARKER)) {

                            int dolPos = chatItem.getMessage().lastIndexOf("$");
                            String names = chatItem.getMessage().substring(0, dolPos);
                            chattingHolder.txvStatus.setText(names + _context.getString(R.string.invited_toroom));

                        } else if (chatItem.getMessage().contains(Constants.KEY_BANISH_MARKER)) {

                            int dolPos = chatItem.getMessage().lastIndexOf("$");
                            String roomname = chatItem.getMessage().substring(0, dolPos);
                            dolPos = roomname.lastIndexOf("$");
                            String names = roomname.substring(0, dolPos);
                            chattingHolder.txvStatus.setText(names + _context.getString(R.string.banish_fromroom));
                        }else if (chatItem.getMessage().contains(Constants.KEY_ADD_MARKER)) {

                            int dolPos = chatItem.getMessage().lastIndexOf("$");
                            String roomname = chatItem.getMessage().substring(0, dolPos);
                            dolPos = roomname.lastIndexOf("$");
                            String name = roomname.substring(0, dolPos);
                            chattingHolder.txvStatus.setText(name + _context.getString(R.string.add_toroom));
                        }

                    } else {

                        chattingHolder.imvMyPhoto.setVisibility(View.VISIBLE);
                        Glide.with(_context).load(_user.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(chattingHolder.imvMyPhoto);
                        chattingHolder.txvTime2.setVisibility(View.VISIBLE);
                        chattingHolder.txvTime2.setText(chatItem.getDisplayTime());

                        // text
                        if (chatItem.getType() == GroupChatItem.ChatType.TEXT) {

                            chattingHolder.txvMyMessage.setVisibility(View.VISIBLE);
                            // emoji
                            if (chatItem.getMessage().startsWith(EmojiFragment.EMOJI_PREFIX) &&
                                    chatItem.getMessage().endsWith(EmojiFragment.EMOJI_SUFFIX)) {

                                int emojiIdx = Integer.parseInt(chatItem.getMessage().substring(EmojiFragment.EMOJI_PREFIX.length(), chatItem.getMessage().indexOf(EmojiFragment.EMOJI_SUFFIX)));
                                chattingHolder.txvMyMessage.setBackgroundResource(EmojiFragment.emoji_ids[emojiIdx]);
                                chattingHolder.txvMyMessage.setText("");

                            } else {
                                chattingHolder.txvMyMessage.setText(chatItem.getMessage());
                                chattingHolder.txvMyMessage.setBackgroundResource(R.drawable.bg_balloon_b);
                            }

                        }
                        // image
                        else if (chatItem.getType() == GroupChatItem.ChatType.IMAGE) {

                            chattingHolder.imvMyImage.setVisibility(View.VISIBLE);

                            int width = chatItem.getImageWidth();
                            int height = chatItem.getImageHeight();

                            if (width == 0)
                                width = BitmapUtils.IMAGE_MAX_SIZE;

                            if (height == 0)
                                height = BitmapUtils.IMAGE_MAX_SIZE;

                            width = width * BitmapUtils.IMAGE_MAX_SIZE / height;
                            height = BitmapUtils.IMAGE_MAX_SIZE;

                            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(width, height);
                            chattingHolder.imvMyImage.setLayoutParams(layoutParams);

                            switch (chatItem.get_status()) {

                                case START_UPLOADING: {

                                    String filepath = BitmapUtils.getUploadFolderPath() + chatItem.getFilename();
                                    Bitmap bitmap = loadBitmap(filepath);

                                    if (bitmap != null) {

                                        chattingHolder.imvMyImage.setImageBitmap(bitmap);
                                        BitmapUtils.setLocked(chattingHolder.imvMyImage);
                                    } else {
                                        chattingHolder.imvMyImage.setImageResource(R.drawable.placeholder);
                                        BitmapUtils.setUnlocked(chattingHolder.imvMyImage);
                                    }

                                    chattingHolder.imvImageProgress2.setVisibility(View.VISIBLE);
                                    AnimationDrawable frameAni = (AnimationDrawable) chattingHolder.imvImageProgress2.getBackground();
                                    frameAni.start();

                                }
                                break;

                                case NORMAL: {

                                    String filepath = BitmapUtils.getUploadFolderPath() + chatItem.getFilename();

                                    Bitmap bitmap = loadBitmap(filepath);

                                    if (bitmap != null) {
                                        chattingHolder.imvMyImage.setImageBitmap(bitmap);
                                        BitmapUtils.setUnlocked(chattingHolder.imvMyImage);
                                    } else {
                                        Glide.with(_context).load(chatItem.getFileUrl()).into(chattingHolder.imvMyImage);
                                        BitmapUtils.setUnlocked(chattingHolder.imvMyImage);
                                    }
                                }
                                break;
                            }

                        }
                        // video
                        else if (chatItem.getType() == GroupChatItem.ChatType.VIDEO) {

                            chattingHolder.fltVideoPreview2.setVisibility(View.VISIBLE);

                            String videoFilePath = chatItem.getFileUrl();
                            String thumbPath = BitmapUtils.getVideoThumbFolderPath() + getVideoThumbName(chatItem.getFilename());
                            Bitmap bitmap = loadBitmap(thumbPath);

                            switch (chatItem.get_status()) {

                                case START_UPLOADING: {

                                    if (bitmap != null) {
                                        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(bitmap.getWidth(), bitmap.getHeight());
                                        chattingHolder.imvVideoPreview2.setLayoutParams(layoutParams);
                                        chattingHolder.imvVideoPreview2.setImageBitmap(bitmap);
                                        BitmapUtils.setLocked(chattingHolder.imvVideoPreview2);
                                        chattingHolder.imvVideoMarker2.setVisibility(View.VISIBLE);
                                    } else {
                                        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                        chattingHolder.imvVideoPreview2.setLayoutParams(layoutParams);
                                        chattingHolder.imvVideoPreview2.setImageResource(R.drawable.nomov);
                                        BitmapUtils.setUnlocked(chattingHolder.imvVideoPreview2);
                                        chattingHolder.imvVideoMarker2.setVisibility(View.GONE);
                                    }

                                    chattingHolder.imvVideoProgress2.setVisibility(View.VISIBLE);
                                    AnimationDrawable frameAni = (AnimationDrawable) chattingHolder.imvVideoProgress2.getBackground();
                                    frameAni.start();

                                }
                                break;


                                case NORMAL: {

                                    if (bitmap != null) {
                                        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(bitmap.getWidth(), bitmap.getHeight());
                                        chattingHolder.imvVideoPreview2.setLayoutParams(layoutParams);
                                        chattingHolder.imvVideoPreview2.setImageBitmap(bitmap);
                                        chattingHolder.imvVideoMarker2.setVisibility(View.VISIBLE);

                                    } else {
                                        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                        chattingHolder.imvVideoPreview2.setLayoutParams(layoutParams);
                                        chattingHolder.imvVideoPreview2.setImageResource(R.drawable.nomov);
                                        chattingHolder.imvVideoMarker2.setVisibility(View.GONE);
                                    }

                                    chattingHolder.imvVideoProgress2.setVisibility(View.GONE);
                                    BitmapUtils.setUnlocked(chattingHolder.imvVideoPreview2);
                                }
                                break;
                            }


                        }
                        // file
//                        else if (chatItem.getType() == GroupChatItem.ChatType.FILE) {
//
//                            chattingHolder.txvMyMessage.setVisibility(View.VISIBLE);
//
//                            switch (chatItem.get_status()) {
//
//                                case START_UPLOADING: {
//
//                                    String filepath = chatItem.getFileUrl();
//
//                                    chattingHolder.txvMyMessage.setText(chatItem.getUploadFileName() + " : " + chatItem.get_progress() + "%");
//
//                                    new Uploadtask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, filepath, String.valueOf(GroupChatItem.ChatType.FILE.ordinal()), chatItem);
//                                    chatItem.set_status(GroupChatItem.StatusType.UPLOADING);
//                                    notifyDataSetChanged();
//                                }
//                                break;
//
//                                case UPLOADING: {
//                                    chattingHolder.txvMyMessage.setText(chatItem.getUploadFileName() + " : " + chatItem.get_progress() + "%");
//                                }
//                                break;
//
//                                case NORMAL: {
//                                    chattingHolder.txvMyMessage.setText(chatItem.getUploadFileName());
//                                }
//                                break;
//                            }
//                        }

                    }

                } else {    // other message

                    FriendEntity friend = _context.get_roomEntity().getParticipant(chatItem.getSender());

                    if (friend != null) {

                        // system
                        if (chatItem.getType() == GroupChatItem.ChatType.SYSTEM) {

                            chattingHolder.txvStatus.setTextColor(0xff919191);
                            chattingHolder.txvStatus.setVisibility(View.VISIBLE);

                            if (chatItem.getMessage().contains(Constants.KEY_LEAVEROOM_MARKER)) {

                                chattingHolder.txvStatus.setText(friend.get_name() + _context.getString(R.string.leave_room));

                            } else if (chatItem.getMessage().contains(Constants.KEY_GROUPNOTI_MARKER)) {

                                chattingHolder.txvStatus.setTextColor(0xff5f99fb);
                                chattingHolder.txvStatus.setText(chatItem.getMessage());

                            } else if (chatItem.getMessage().contains(Constants.KEY_DELEGATE_MARKER)) {

                                int dolPos = chatItem.getMessage().lastIndexOf("$");
                                String roomname = chatItem.getMessage().substring(0, dolPos);
                                dolPos = roomname.lastIndexOf("$");
                                String name = roomname.substring(0, dolPos);
                                chattingHolder.txvStatus.setText(name + _context.getString(R.string.become_groupowner));

                            }else if (chatItem.getMessage().contains(Constants.KEY_INVITE_MARKER)) {

                                int dolPos = chatItem.getMessage().lastIndexOf("$");
                                String names = chatItem.getMessage().substring(0, dolPos);
                                chattingHolder.txvStatus.setText(names + _context.getString(R.string.invited_toroom));

                            } else if (chatItem.getMessage().contains(Constants.KEY_BANISH_MARKER)) {

                                int dolPos = chatItem.getMessage().lastIndexOf("$");
                                String roomname = chatItem.getMessage().substring(0, dolPos);
                                dolPos = roomname.lastIndexOf("$");
                                String names = roomname.substring(0, dolPos);
                                chattingHolder.txvStatus.setText(names + _context.getString(R.string.banish_fromroom));
                            } else if (chatItem.getMessage().contains(Constants.KEY_ADD_MARKER)) {

                                int dolPos = chatItem.getMessage().lastIndexOf("$");
                                String roomname = chatItem.getMessage().substring(0, dolPos);
                                dolPos = roomname.lastIndexOf("$");
                                String name = roomname.substring(0, dolPos);
                                chattingHolder.txvStatus.setText(name + _context.getString(R.string.add_toroom));

                            }

                        } else {

                            chattingHolder.imvFriendPhoto.setVisibility(View.VISIBLE);
                            //chattingHolder.txvFriendName.setVisibility(View.VISIBLE);
                            chattingHolder.txvTime1.setVisibility(View.VISIBLE);

                            Glide.with(_context).load(friend.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(chattingHolder.imvFriendPhoto);
                            chattingHolder.txvFriendName.setText(friend.get_name());
                            chattingHolder.txvTime1.setText(chatItem.getDisplayTime());

                            // text
                            if (chatItem.getType() == GroupChatItem.ChatType.TEXT) {

                                chattingHolder.txvFriendMessage.setVisibility(View.VISIBLE);

                                // emoji
                                if (chatItem.getMessage().startsWith(EmojiFragment.EMOJI_PREFIX) &&
                                        chatItem.getMessage().endsWith(EmojiFragment.EMOJI_SUFFIX)) {

                                    int emojiIdx = Integer.parseInt(chatItem.getMessage().substring(EmojiFragment.EMOJI_PREFIX.length(), chatItem.getMessage().indexOf(EmojiFragment.EMOJI_SUFFIX)));
                                    chattingHolder.txvFriendMessage.setBackgroundResource(EmojiFragment.emoji_ids[emojiIdx]);
                                    chattingHolder.txvFriendMessage.setText("");

                                } else {

                                    chattingHolder.txvFriendMessage.setText(chatItem.getMessage());
                                    chattingHolder.txvFriendMessage.setBackgroundResource(R.drawable.bg_balloon_g);
                                    chattingHolder.txvFriendMessage.setPadding(Commons.GetPixelValueFromDp(_context, 16), Commons.GetPixelValueFromDp(_context, 8), Commons.GetPixelValueFromDp(_context, 8), Commons.GetPixelValueFromDp(_context, 8));

                                }

                            }
                            // image
                            else if (chatItem.getType() == GroupChatItem.ChatType.IMAGE) {

                                chattingHolder.imvFriendImage.setVisibility(View.VISIBLE);

                                int width = chatItem.getImageWidth();
                                int height = chatItem.getImageHeight();
                                width = width * BitmapUtils.IMAGE_MAX_SIZE / height;
                                height = BitmapUtils.IMAGE_MAX_SIZE;

                                FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(width, height);
                                chattingHolder.imvFriendImage.setLayoutParams(layoutParams);

                                Glide.with(_context).load(chatItem.getFileUrl()).into(chattingHolder.imvFriendImage);

                            }
                            // video
                            else if (chatItem.getType() == GroupChatItem.ChatType.VIDEO) {

                                chattingHolder.fltVideoPreview1.setVisibility(View.VISIBLE);

                                String videoFileUrl = chatItem.getFileUrl();
                                String thumbPath = BitmapUtils.getVideoThumbFolderPath() + getVideoThumbName(chatItem.getFilename());
                                String videoLocalPath = BitmapUtils.getDownloadFolderPath() + chatItem.getFilename();
                                Bitmap bitmap = loadBitmap(thumbPath);
                                File file = new File(videoLocalPath);

                                switch (chatItem.get_status()) {

                                    case NORMAL: {

                                        if (file.exists()) {

                                            if (bitmap == null)
                                                bitmap = _context.saveThumbnail(videoLocalPath);

                                            if (bitmap != null) {
                                                FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(bitmap.getWidth(), bitmap.getHeight());
                                                chattingHolder.imvVideoPreview1.setLayoutParams(layoutParams);
                                                chattingHolder.imvVideoPreview1.setImageBitmap(bitmap);
                                                chattingHolder.imvVideoMarker1.setVisibility(View.VISIBLE);
                                            } else {
                                                FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                                chattingHolder.imvVideoPreview1.setLayoutParams(layoutParams);
                                                chattingHolder.imvVideoPreview1.setImageResource(R.drawable.nomov);
                                                chattingHolder.imvVideoMarker1.setVisibility(View.GONE);
                                            }

                                            chattingHolder.imvVideoProgress1.setVisibility(View.GONE);
                                            BitmapUtils.setUnlocked(chattingHolder.imvVideoPreview1);

                                            if (_firstNormal) {
                                                notifyDataSetChanged();
                                                _firstNormal = false;
                                            }

                                        } else {
                                            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                            chattingHolder.imvVideoPreview1.setLayoutParams(layoutParams);
                                            chattingHolder.imvVideoPreview1.setImageResource(R.drawable.nomov);
                                            chattingHolder.imvVideoMarker1.setVisibility(View.GONE);

                                            chatItem.set_status(GroupChatItem.StatusType.DOWNLOADING);
                                            new DownloadTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, videoFileUrl, chatItem.getFilename(), chatItem);

                                            chattingHolder.imvVideoProgress1.setVisibility(View.VISIBLE);
                                            AnimationDrawable frameAni = (AnimationDrawable) chattingHolder.imvVideoProgress1.getBackground();
                                            frameAni.start();

                                            notifyDataSetChanged();
                                        }

                                    }
                                    break;

                                    case DOWNLOADING: {
                                        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                        chattingHolder.imvVideoPreview1.setLayoutParams(layoutParams);
                                        chattingHolder.imvVideoPreview1.setImageResource(R.drawable.nomov);
                                        chattingHolder.imvVideoMarker1.setVisibility(View.GONE);
                                        chattingHolder.imvVideoProgress1.setVisibility(View.VISIBLE);
                                        AnimationDrawable frameAni = (AnimationDrawable) chattingHolder.imvVideoProgress1.getBackground();
                                        frameAni.start();
                                    }

                                    break;
                                }


                            }
                            // file
                            else if (chatItem.getType() == GroupChatItem.ChatType.FILE) {

                                chattingHolder.txvFriendMessage.setVisibility(View.VISIBLE);

                                String fileUrl = chatItem.getFileUrl();

                                switch (chatItem.get_status()) {

                                    case START_DOWNLOADING: {
                                        new DownloadTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, fileUrl, chatItem.getFilename(), chatItem);
                                        chatItem.set_status(GroupChatItem.StatusType.DOWNLOADING);
                                        chattingHolder.txvFriendMessage.setText(chatItem.getUploadFileName() + " : " + chatItem.get_progress() + "%");
                                        notifyDataSetChanged();
                                    }
                                    break;

                                    case DOWNLOADING:
                                        chattingHolder.txvFriendMessage.setText(chatItem.getUploadFileName() + " : " + chatItem.get_progress() + "%");
                                        break;

                                    case NORMAL:
                                        chattingHolder.txvFriendMessage.setText(chatItem.getUploadFileName());
                                        break;

                                }
                            }
                        }
                    } else {

                        if (chatItem.getType() == GroupChatItem.ChatType.SYSTEM) {

                            chattingHolder.txvStatus.setVisibility(View.VISIBLE);

                            if (chatItem.getMessage().contains(Constants.KEY_LEAVEROOM_MARKER)) {

                                chattingHolder.txvStatus.setTextColor(0xff919191);
                                int dolPos = chatItem.getMessage().lastIndexOf("$");
                                String name = chatItem.getMessage().substring(0, dolPos);

                                chattingHolder.txvStatus.setText(name +  _context.getString(R.string.leave_room));
                            } else if (chatItem.getMessage().contains(Constants.KEY_GROUPNOTI_MARKER)) {

                                chattingHolder.txvStatus.setTextColor(0xff5f99fb);
                                chattingHolder.txvStatus.setText(chatItem.getMessage());

                            }

                        }

                    }

                }

                chattingHolder.imvMyImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        _context.onItemClick(chatItem);
                    }
                });

                chattingHolder.imvFriendImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        _context.onItemClick(chatItem);
                    }
                });

                chattingHolder.imvVideoPreview1.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        _context.onItemClick(chatItem);
                    }
                });

                chattingHolder.imvVideoPreview2.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        _context.onItemClick(chatItem);
                    }
                });

                return convertView;
            }
        }
    }

    public void addItem(GroupChatItem entity){

        SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
        DateFormat outFormat = DateFormat.getDateInstance(DateFormat.LONG);

        String time = entity.getTime().split(",")[0];

        try {

            Date date = df.parse(time);
            if (_lastDate == null || _lastDate.before(date)) {

                String strDate = outFormat.format(date);
                _chatList.add(strDate);
                _lastDate = date;
            }
        } catch (Exception ex) {
        }

        _chatList.add(entity);
    }

    public void addItems(ArrayList<GroupChatItem> items) {

        for (GroupChatItem item : items)
            addItem(item);
    }


    public String getVideoThumbName(String filename) {

        int pos = filename.lastIndexOf(".");
        if (pos > 0) {
            filename = filename.substring(0, pos);
        }

        filename += ".png";

        return filename;
    }


    public void addBitmapToMemoryCache(String key, Bitmap bitmap) {
        if (getBitmapFromMemCache(key) == null) {
            mMemoryCache.put(key, bitmap);
        }
    }

    public Bitmap getBitmapFromMemCache(String key) {
        return mMemoryCache.get(key);
    }

    public Bitmap loadBitmap(String filepath) {

        Bitmap bitmap = getBitmapFromMemCache(filepath);

        if (bitmap != null) {
            return bitmap;

        } else {
            bitmap = BitmapUtils.decodeFile(filepath);

            if (bitmap != null)
                addBitmapToMemoryCache(filepath, bitmap);

            return bitmap;
        }
    }

    public void setFileUrl(GroupChatItem chatItem, String fileUrl) {

        String localPath = chatItem.getFileUrl();

        String message = chatItem.getMessage();
        message = message.replace(localPath, fileUrl);

        chatItem.setMessage(message);

    }

    public class ChattingHolder {

        public CircleImageView imvFriendPhoto;
        public TextView txvFriendName;
        public TextView txvFriendMessage;
        public ImageView imvFriendImage;
        public TextView txvTime1;
        public FrameLayout fltVideoPreview1;
        public ImageView imvVideoPreview1;
        public ImageView imvVideoMarker1;
        public ImageView imvVideoProgress1;

        public CircleImageView imvMyPhoto;
        public TextView txvMyMessage;
        public ImageView imvMyImage;
        public ImageView imvImageProgress2;
        public TextView txvTime2;
        public FrameLayout fltVideoPreview2;
        public ImageView imvVideoPreview2;
        public ImageView imvVideoProgress2;
        public ImageView imvVideoMarker2;

        public TextView txvStatus;

    }

    public class DateHolder {

        public TextView txvDate;
    }

//
//
//    private class Uploadtask extends AsyncTask<Object, Integer, String> {
//
//        long totalSize = 0;
//        GroupChatItem _chatItem = null;
//
//        @Override
//        protected void onPreExecute() {
//            super.onPreExecute();
//        }
//
//        @Override
//        protected void onProgressUpdate(Integer... progress) {
//
//            _chatItem.set_progress(progress[0]);
//
//            if (_chatItem.getType() == GroupChatItem.ChatType.FILE)
//                notifyDataSetChanged();
//
//        }
//
//        @Override
//        protected String doInBackground(Object... params) {
//
//            com.julyseven.wonbridge.logger.Logger.d("TEST", "adapter doinbackground:" + params[0]);
//
//            String filename = (String) params[0];
//            String type = (String) params[1];
//            _chatItem = (GroupChatItem) params[2];
//            return upload(filename, type);
//        }
//
//        private String upload(String filepath, String type) {
//
//            String responseString = "no";
//            String urlString = ReqConst.SERVER_URL + ReqConst.REQ_UPLOADFILE;
//
//            File sourceFile = new File(filepath);
//            if (!sourceFile.isFile()) {
//                return responseString;
//            }
//
//            HttpClient httpclient = new DefaultHttpClient();
//            HttpPost httppost = new HttpPost(urlString);
//
//            try {
//                CustomMultiPartEntity entity = new CustomMultiPartEntity(new CustomMultiPartEntity.ProgressListener() {
//
//                    @Override
//                    public void transferred(long num) {
//                        publishProgress((int) ((num / (float) totalSize) * 100));
//                    }
//                });
//
//                String filename = Commons.fileNameWithExtFromPath(filepath);
//                filename = URLEncoder.encode(filename, "utf-8").replace("+", "%20");
//
//                entity.addPart(ReqConst.PARAM_ID, new StringBody(String.valueOf(_user.get_idx())));
//                entity.addPart(ReqConst.PARAM_TYPE, new StringBody(type));
//                entity.addPart(ReqConst.PARAM_FILENAME, new StringBody(filename));
//                entity.addPart(ReqConst.PARAM_FILE, new FileBody(sourceFile));
//                totalSize = entity.getContentLength();
//                httppost.setEntity(entity);
//                HttpResponse response = httpclient.execute(httppost);
//                HttpEntity r_entity = response.getEntity();
//                responseString = EntityUtils.toString(r_entity);
//
//            } catch (ClientProtocolException e) {
//                e.printStackTrace();
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//
//            return responseString;
//
//        }
//
//        @Override
//        protected void onPostExecute(String result) {
//
//            try {
//
//                JSONObject response = new JSONObject(result);
//
//                int resultCode = response.getInt(ReqConst.RES_CODE);
//
//                if (resultCode == ReqConst.CODE_SUCCESS) {
//
//                    _chatItem.set_status(GroupChatItem.StatusType.NORMAL);
//
//                    String file = response.getString(ReqConst.RES_FILE_URL);
//                    String filename = response.getString(ReqConst.RES_FILENAME);
//                    setFileUrl(_chatItem, file);
//                    _context.onSuccessUpload(file, filename, _chatItem);
//
//                } else {
//                    _chatList.remove(_chatItem);
//                    _context.onFailUpload();
//                }
//
//            } catch (Exception ex) {
//                _chatList.remove(_chatItem);
//                _context.onFailUpload();
//            }
//
//            notifyDataSetChanged();
//
//            super.onPostExecute(result);
//
//        }
//
//    }

    private class DownloadTask extends AsyncTask<Object, Integer, String> {

        GroupChatItem _chatItem = null;

        @Override
        protected void onProgressUpdate(Integer... progress) {

            _chatItem.set_progress(progress[0]);

            if (_chatItem.getType() == GroupChatItem.ChatType.FILE)
                notifyDataSetChanged();

        }

        @Override
        protected String doInBackground(Object... params) {

            InputStream input = null;
            OutputStream output = null;
            HttpURLConnection connection = null;

            String strUrl = (String) params[0];
            String outfile = BitmapUtils.getDownloadFolderPath() + (String) params[1];
            _chatItem = (GroupChatItem) params[2];

            String returned = "";

            try {

                URL url = new URL(strUrl);

                connection = (HttpURLConnection) url.openConnection();
                connection.connect();

                // expect HTTP 200 OK, so we don't mistakenly save error report
                // instead of the file
                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    return "Server returned HTTP " + connection.getResponseCode()
                            + " " + connection.getResponseMessage();
                }

                // this will be useful to display download percentage
                // might be -1: server did not report the length
                int fileLength = connection.getContentLength();

                // download the file
                input = connection.getInputStream();
                output = new FileOutputStream(outfile);

                byte data[] = new byte[4096];
                long total = 0;
                int count;
                while ((count = input.read(data)) != -1) {
                    // allow canceling with back button
                    if (isCancelled()) {
                        input.close();
                        return null;
                    }
                    total += count;
                    // publishing the progress....
                    if (fileLength > 0) // only if total length is known
                        publishProgress((int) (total * 100 / fileLength));

                    output.write(data, 0, count);

                }

                returned = outfile;

            } catch (Exception e) {
                return "";
            } finally {
                try {
                    if (output != null)
                        output.close();
                    if (input != null)
                        input.close();
                } catch (IOException ignored) {
                }

                if (connection != null)
                    connection.disconnect();
            }
            return returned;
        }

        @Override
        protected void onPostExecute(String result) {

            _chatItem.set_status(GroupChatItem.StatusType.NORMAL);

            if (result.length() > 0 && _chatItem.getType() == GroupChatItem.ChatType.VIDEO) {
                _context.saveThumbnail(result);
            }

            notifyDataSetChanged();

            _firstNormal = true;

            com.julyseven.wonbridge.logger.Logger.d("FILE", "writing file completed");

            super.onPostExecute(result);

        }
    }
}
