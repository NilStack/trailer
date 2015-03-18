
#if os(iOS)
import UIKit
#endif

var _settings_valuesCache = Dictionary<String, AnyObject>()
let _settings_shared = NSUserDefaults(suiteName: "group.Trailer")!

class Settings: NSObject {

    class func checkMigration() {

        let allFields = [
            "SORT_METHOD_KEY", "STATUS_FILTERING_METHOD_KEY", "LAST_PREFS_TAB_SELECTED", "CLOSE_HANDLING_POLICY", "MERGE_HANDLING_POLICY", "STATUS_ITEM_REFRESH_COUNT", "LABEL_REFRESH_COUNT", "UPDATE_CHECK_INTERVAL_KEY",
            "STATUS_FILTERING_TERMS_KEY", "COMMENT_AUTHOR_BLACKLIST", "HOTKEY_LETTER", "REFRESH_PERIOD_KEY", "IOS_BACKGROUND_REFRESH_PERIOD_KEY", "NEW_REPO_CHECK_PERIOD", "LAST_SUCCESSFUL_REFRESH",
            "LAST_RUN_VERSION_KEY", "UPDATE_CHECK_AUTO_KEY", "HIDE_UNCOMMENTED_PRS_KEY", "SHOW_COMMENTS_EVERYWHERE_KEY", "SORT_ORDER_KEY", "SHOW_UPDATED_KEY", "DONT_KEEP_MY_PRS_KEY", "HIDE_AVATARS_KEY",
            "AUTO_PARTICIPATE_IN_MENTIONS_KEY", "DONT_ASK_BEFORE_WIPING_MERGED", "DONT_ASK_BEFORE_WIPING_CLOSED", "HIDE_NEW_REPOS_KEY", "GROUP_BY_REPO", "HIDE_ALL_SECTION", "SHOW_LABELS", "SHOW_STATUS_ITEMS",
            "MAKE_STATUS_ITEMS_SELECTABLE", "MOVE_ASSIGNED_PRS_TO_MY_SECTION", "MARK_UNMERGEABLE_ON_USER_SECTIONS_ONLY", "COUNT_ONLY_LISTED_PRS", "OPEN_PR_AT_FIRST_UNREAD_COMMENT_KEY", "LOG_ACTIVITY_TO_CONSOLE_KEY",
            "HOTKEY_ENABLE", "HOTKEY_CONTROL_MODIFIER", "USE_VIBRANCY_UI", "DISABLE_ALL_COMMENT_NOTIFICATIONS", "NOTIFY_ON_STATUS_UPDATES", "NOTIFY_ON_STATUS_UPDATES_ALL", "SHOW_REPOS_IN_NAME", "INCLUDE_REPOS_IN_FILTER",
            "INCLUDE_LABELS_IN_FILTER", "INCLUDE_STATUSES_IN_FILTER", "HOTKEY_COMMAND_MODIFIER", "HOTKEY_OPTION_MODIFIER", "HOTKEY_SHIFT_MODIFIER", "GRAY_OUT_WHEN_REFRESHING"]

        let d = NSUserDefaults.standardUserDefaults()
        if d.objectForKey("LAST_RUN_VERSION_KEY") != nil {
            for k in allFields {
                if let v: AnyObject = d.objectForKey(k) {
                    _settings_shared.setObject(v, forKey: k)
                    DLog("Migrating setting '%@'", k)
                    d.removeObjectForKey(k)
                }
            }
            _settings_shared.synchronize()
            DLog("Settings migrated to shared container")
        } else {
            DLog("No need to migrate settings into shared container")
        }
    }

	private class func set(key: String, _ value: NSObject?) {
		if let v = value {
			_settings_shared.setObject(v, forKey: key)
		} else {
			_settings_shared.removeObjectForKey(key)
		}
		_settings_valuesCache[key] = value
		_settings_shared.synchronize()

		DLog("Setting %@ to %@", key, value)
	}

	private class func get(key: String) -> AnyObject? {
		if let v: AnyObject = _settings_valuesCache[key] {
			return v
		} else {
			if let vv: AnyObject = _settings_shared.objectForKey(key) {
				_settings_valuesCache[key] = vv
				return vv
			} else {
				return nil
			}
		}
	}

	class func clearCache() {
		_settings_valuesCache.removeAll(keepCapacity: false)
	}

	/////////////////////////////////

	class var sortMethod: Int {
		get { return get("SORT_METHOD_KEY") as? Int ?? 0 }
		set { set("SORT_METHOD_KEY", newValue) }
	}

	class var statusFilteringMode: Int {
		get { return get("STATUS_FILTERING_METHOD_KEY") as? Int ?? 0 }
		set { set("STATUS_FILTERING_METHOD_KEY", newValue) }
	}

	class var lastPreferencesTabSelected: Int {
		get { return get("LAST_PREFS_TAB_SELECTED") as? Int ?? 0 }
		set { set("LAST_PREFS_TAB_SELECTED", newValue) }
	}

	class var closeHandlingPolicy: Int {
		get { return get("CLOSE_HANDLING_POLICY") as? Int ?? 0 }
		set { set("CLOSE_HANDLING_POLICY", newValue) }
	}

	class var mergeHandlingPolicy: Int {
		get { return get("MERGE_HANDLING_POLICY") as? Int ?? 0 }
		set { set("MERGE_HANDLING_POLICY", newValue) }
	}

	class var statusItemRefreshInterval: Int {
		get { if let n = get("STATUS_ITEM_REFRESH_COUNT") as? Int { return n>0 ? n : 10 } else { return 10 } }
		set { set("STATUS_ITEM_REFRESH_COUNT", newValue) }
	}

	class var labelRefreshInterval: Int {
		get { if let n = get("LABEL_REFRESH_COUNT") as? Int { return n>0 ? n : 4 } else { return 4 } }
		set { set("LABEL_REFRESH_COUNT", newValue) }
	}

	class var checkForUpdatesInterval: Int {
		get { return get("UPDATE_CHECK_INTERVAL_KEY") as? Int ?? 8 }
		set { set("UPDATE_CHECK_INTERVAL_KEY", newValue) }
	}

	///////////////////////////

	class var statusFilteringTerms: [String] {
		get { return get("STATUS_FILTERING_TERMS_KEY") as? [String] ?? [] }
		set { set("STATUS_FILTERING_TERMS_KEY", newValue) }
	}

	class var commentAuthorBlacklist: [String] {
		get { return get("COMMENT_AUTHOR_BLACKLIST") as? [String] ?? [] }
		set { set("COMMENT_AUTHOR_BLACKLIST", newValue) }
	}

	class var hotkeyLetter: String {
		get { return get("HOTKEY_LETTER") as? String ?? "T" }
		set { set("HOTKEY_LETTER", newValue) }
	}

	///////////////////////////

	class var refreshPeriod: Float {
		get { if let n = get("REFRESH_PERIOD_KEY") as? Float { return n < 60 ? 120 : n } else { return 120 } }
		set { set("REFRESH_PERIOD_KEY", newValue) }
	}

	class var backgroundRefreshPeriod: Float {
		get { if let n = get("IOS_BACKGROUND_REFRESH_PERIOD_KEY") as? Float { return n > 0 ? n : 1800 } else { return 1800 } }
		set {
			set("IOS_BACKGROUND_REFRESH_PERIOD_KEY", newValue)
			#if os(iOS)
            app.setMinimumBackgroundFetchInterval(NSTimeInterval(newValue))
			#endif
		}
	}

	class var newRepoCheckPeriod: Float {
		get { if let n = get("NEW_REPO_CHECK_PERIOD") as? Float { return max(n, 2) } else { return 2 } }
		set { set("NEW_REPO_CHECK_PERIOD", newValue) }
	}

	///////////////////////////

    class var lastSuccessfulRefresh: NSDate? {
        get { return get("LAST_SUCCESSFUL_REFRESH") as? NSDate }
        set { set("LAST_SUCCESSFUL_REFRESH", newValue) }
    }

    class var lastRunVersion: String? {
        get { return get("LAST_RUN_VERSION_KEY") as? String }
        set { set("LAST_RUN_VERSION_KEY", newValue) }
    }

    ///////////////////////////

	class var checkForUpdatesAutomatically: Bool {
		get { return get("UPDATE_CHECK_AUTO_KEY") as? Bool ?? true }
		set { set("UPDATE_CHECK_AUTO_KEY", newValue) }
	}

	class var shouldHideUncommentedRequests: Bool {
		get { return get("HIDE_UNCOMMENTED_PRS_KEY") as? Bool ?? false }
		set { set("HIDE_UNCOMMENTED_PRS_KEY", newValue) }
	}

	class var showCommentsEverywhere: Bool {
		get { return get("SHOW_COMMENTS_EVERYWHERE_KEY") as? Bool ?? false }
		set { set("SHOW_COMMENTS_EVERYWHERE_KEY", newValue) }
	}

	class var sortDescending: Bool {
		get { return get("SORT_ORDER_KEY") as? Bool ?? false }
		set { set("SORT_ORDER_KEY", newValue) }
	}

	class var showCreatedInsteadOfUpdated: Bool {
		get { return get("SHOW_UPDATED_KEY") as? Bool ?? false }
		set { set("SHOW_UPDATED_KEY", newValue) }
	}

	class var dontKeepPrsMergedByMe: Bool {
		get { return get("DONT_KEEP_MY_PRS_KEY") as? Bool ?? false }
		set { set("DONT_KEEP_MY_PRS_KEY", newValue) }
	}

	class var hideAvatars: Bool {
		get { return get("HIDE_AVATARS_KEY") as? Bool ?? false }
		set { set("HIDE_AVATARS_KEY", newValue) }
	}

	class var autoParticipateInMentions: Bool {
		get { return get("AUTO_PARTICIPATE_IN_MENTIONS_KEY") as? Bool ?? false }
		set { set("AUTO_PARTICIPATE_IN_MENTIONS_KEY", newValue) }
	}

	class var dontAskBeforeWipingMerged: Bool {
		get { return get("DONT_ASK_BEFORE_WIPING_MERGED") as? Bool ?? false }
		set { set("DONT_ASK_BEFORE_WIPING_MERGED", newValue) }
	}

	class var dontAskBeforeWipingClosed: Bool {
		get { return get("DONT_ASK_BEFORE_WIPING_CLOSED") as? Bool ?? false }
		set { set("DONT_ASK_BEFORE_WIPING_CLOSED", newValue) }
	}

	class var hideNewRepositories: Bool {
		get { return get("HIDE_NEW_REPOS_KEY") as? Bool ?? false }
		set { set("HIDE_NEW_REPOS_KEY", newValue) }
	}

	class var groupByRepo: Bool {
		get { return get("GROUP_BY_REPO") as? Bool ?? false }
		set { set("GROUP_BY_REPO", newValue) }
	}

	class var hideAllPrsSection: Bool {
		get { return get("HIDE_ALL_SECTION") as? Bool ?? false }
		set { set("HIDE_ALL_SECTION", newValue) }
	}

	class var showLabels: Bool {
		get { return get("SHOW_LABELS") as? Bool ?? false }
		set { set("SHOW_LABELS", newValue) }
	}

	class var showStatusItems: Bool {
		get { return get("SHOW_STATUS_ITEMS") as? Bool ?? false }
		set { set("SHOW_STATUS_ITEMS", newValue) }
	}

	class var makeStatusItemsSelectable: Bool {
		get { return get("MAKE_STATUS_ITEMS_SELECTABLE") as? Bool ?? false }
		set { set("MAKE_STATUS_ITEMS_SELECTABLE", newValue) }
	}

	class var moveAssignedPrsToMySection: Bool {
		get { return get("MOVE_ASSIGNED_PRS_TO_MY_SECTION") as? Bool ?? false }
		set { set("MOVE_ASSIGNED_PRS_TO_MY_SECTION", newValue) }
	}

	class var markUnmergeableOnUserSectionsOnly: Bool {
		get { return get("MARK_UNMERGEABLE_ON_USER_SECTIONS_ONLY") as? Bool ?? false }
		set { set("MARK_UNMERGEABLE_ON_USER_SECTIONS_ONLY", newValue) }
	}

	class var countOnlyListedPrs: Bool {
		get { return get("COUNT_ONLY_LISTED_PRS") as? Bool ?? false }
		set { set("COUNT_ONLY_LISTED_PRS", newValue) }
	}

	class var openPrAtFirstUnreadComment: Bool {
		get { return get("OPEN_PR_AT_FIRST_UNREAD_COMMENT_KEY") as? Bool ?? false }
		set { set("OPEN_PR_AT_FIRST_UNREAD_COMMENT_KEY", newValue) }
	}

	class var logActivityToConsole: Bool {
		get { return get("LOG_ACTIVITY_TO_CONSOLE_KEY") as? Bool ?? false }
		set { set("LOG_ACTIVITY_TO_CONSOLE_KEY", newValue) }
	}

	class var hotkeyEnable: Bool {
		get { return get("HOTKEY_ENABLE") as? Bool ?? false }
		set { set("HOTKEY_ENABLE", newValue) }
	}

	class var hotkeyControlModifier: Bool {
		get { return get("HOTKEY_CONTROL_MODIFIER") as? Bool ?? false }
		set { set("HOTKEY_CONTROL_MODIFIER", newValue) }
	}

	class var useVibrancy: Bool {
		get { return get("USE_VIBRANCY_UI") as? Bool ?? false }
		set { set("USE_VIBRANCY_UI", newValue) }
	}

    class var disableAllCommentNotifications: Bool {
        get { return get("DISABLE_ALL_COMMENT_NOTIFICATIONS") as? Bool ?? false }
        set { set("DISABLE_ALL_COMMENT_NOTIFICATIONS", newValue) }
    }

    class var notifyOnStatusUpdates: Bool {
        get { return get("NOTIFY_ON_STATUS_UPDATES") as? Bool ?? false }
        set { set("NOTIFY_ON_STATUS_UPDATES", newValue) }
    }

    class var notifyOnStatusUpdatesForAllPrs: Bool {
        get { return get("NOTIFY_ON_STATUS_UPDATES_ALL") as? Bool ?? false }
        set { set("NOTIFY_ON_STATUS_UPDATES_ALL", newValue) }
    }

	class var autoParticipateOnTeamMentions: Bool {
		get { return get("AUTO_PARTICIPATE_ON_TEAM_MENTIONS") as? Bool ?? false }
		set { set("AUTO_PARTICIPATE_ON_TEAM_MENTIONS", newValue) }
	}

	//////////////////////////////

	class var showReposInName: Bool {
		get { return get("SHOW_REPOS_IN_NAME") as? Bool ?? true }
		set { set("SHOW_REPOS_IN_NAME", newValue) }
	}

	class var includeReposInFilter: Bool {
		get { return get("INCLUDE_REPOS_IN_FILTER") as? Bool ?? true }
		set { set("INCLUDE_REPOS_IN_FILTER", newValue) }
	}

	class var includeLabelsInFilter: Bool {
		get { return get("INCLUDE_LABELS_IN_FILTER") as? Bool ?? true }
		set { set("INCLUDE_LABELS_IN_FILTER", newValue) }
	}

	class var includeStatusesInFilter: Bool {
		get { return get("INCLUDE_STATUSES_IN_FILTER") as? Bool ?? true }
		set { set("INCLUDE_STATUSES_IN_FILTER", newValue) }
	}

	class var hotkeyCommandModifier: Bool {
		get { return get("HOTKEY_COMMAND_MODIFIER") as? Bool ?? true }
		set { set("HOTKEY_COMMAND_MODIFIER", newValue) }
	}

	class var hotkeyOptionModifier: Bool {
		get { return get("HOTKEY_OPTION_MODIFIER") as? Bool ?? true }
		set { set("HOTKEY_OPTION_MODIFIER", newValue) }
	}

	class var hotkeyShiftModifier: Bool {
		get { return get("HOTKEY_SHIFT_MODIFIER") as? Bool ?? true }
		set { set("HOTKEY_SHIFT_MODIFIER", newValue) }
	}

    class var grayOutWhenRefreshing: Bool {
		get { return get("GRAY_OUT_WHEN_REFRESHING") as? Bool ?? true }
		set { set("GRAY_OUT_WHEN_REFRESHING", newValue) }
    }
}
