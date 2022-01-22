package com.julyseven.wonbridge.logger;


import com.julyseven.wonbridge.utils.BitmapUtils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Log class
 * 
 * 배포 시 DEBUG = false 로 설정
 * 
 * @author Kris
 */
public final class Logger {

	private static final String TAG = Logger.class.getSimpleName();

	public static final boolean DEBUG = true;

    /**
     * verbose log print
     * 
     * @param String
     * @param String
     * 
     * @return int
     */
    public static int v(String tag, String msg) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.v(tag, msg);
    }

    /**
     * verbose log print
     * 
     * @param String
     * @param String
     * @param Throwable
     * 
     * @return int
     */
    public static int v(String tag, String msg, Throwable tr) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.v(tag, msg, tr);
    }

    /**
     * error log print
     * 
     * @param String
     * @param String
     * 
     * @return int
     */
    public static int e(String tag, String msg) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.e(tag, msg);
    }

    /**
     * error log print
     * 
     * @param String
     * @param String
     * @param Throwable
     * 
     * @return int
     */
    public static int e(String tag, String msg, Throwable tr) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.e(tag, msg, tr);
    }

    /**
     * worn log print
     * 
     * @param String
     * @param String
     * 
     * @return int
     */
    public static int w(String tag, String msg) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.w(tag, msg);
    }

    /**
     * worn log print
     * 
     * @param String
     * @param String
     * @param Throwable
     * 
     * @return int
     */
    public static int w(String tag, String msg, Throwable tr) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.w(tag, msg, tr);
    }

    /**
     * info log print
     * 
     * @param String
     * @param String
     * 
     * @return int
     */
    public static int i(String tag, String msg) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.i(tag, msg);
    }

    /**
     * info log print
     * 
     * @param String
     * @param String
     * @param Throwable
     * 
     * @return int
     */
    public static int i(String tag, String msg, Throwable tr) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.i(tag, msg, tr);
    }

    /**
     * debug log print
     * 
     * @param String
     * @param String
     * 
     * @return int
     */
    public static int d(String tag, String msg) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.d(tag, msg);
    }

    /**
     * debug log print
     * 
     * @param String
     * @param String
     * @param Throwable
     * 
     * @return int
     */
    public static int d(String tag, String msg, Throwable tr) {
        if (!DEBUG) {
            return -1;
        }
        msg = tag + " - " + msg;
        // writeLog(tag, msg);
        return android.util.Log.d(tag, msg, tr);
    }

	/**
	 * debug log print
	 * 
	 * @param String
	 * @param String
	 * 
	 * @return int
	 */
	public static int s(String tag, String msg) {
		if (!DEBUG) {
			return -1;
		}
		msg = tag + " - " + msg;
		writeLog(tag, msg);
		return android.util.Log.e(tag, msg);
	}

	/**
	 * debug log print
	 * 
	 * @param String
	 * @param String
	 * @param Throwable
	 * 
	 * @return int
	 */
	public static int s(String tag, String msg, Throwable tr) {
		if (!DEBUG) {
			return -1;
		}
		msg = tag + " - " + msg;
		writeLog(tag, msg);
		return android.util.Log.e(tag, msg, tr);
	}

	private static void writeLog(String tag, String log) {
		if (!DEBUG) {
			return;
		}

		String path = BitmapUtils.getLocalFolderPath();
		String fileName = "dchat_log.txt";
		File file = new File(path + fileName);

		try {

			if (!file.exists()) {
				file.createNewFile();
			}

			FileWriter fw = new FileWriter(file, true);
			BufferedWriter bw = new BufferedWriter(fw);

			bw.newLine();
			bw.append(log);

			bw.flush();
			bw.close();

		} catch (FileNotFoundException e) {
			Logger.e(TAG,
					"writeLog - FileNotFoundException : " + e.getMessage());
		} catch (IOException e) {
			Logger.e(TAG, "writeLog - IOException : " + e.getMessage());
		} catch (Exception e) {
			Logger.e(TAG, "writeLog - Exception : " + e.getMessage());
		}
	}

}