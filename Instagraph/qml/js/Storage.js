function getDatabase() {
    var db = LocalStorage.openDatabaseSync("InstagraphAppm", "0.1", "SettingsDatabase", 100000);

    db.transaction(function(tx) {
        tx.executeSql(
            'CREATE TABLE IF NOT EXISTS accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT, profilePicUrl TEXT)');
    });

    return db;
}

function insertAccount(username, password) {
    var db = getDatabase();
    var res = false;
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO accounts(username, password) VALUES (?, ?);', [username, password]);
        if (rs.rowsAffected > 0) {
            res = true;
        } else {
            res = false;
        }
    });
    return res;
}

function updateProfilePic(username, profilePicUrl) {
    var db = getDatabase();
    var res = false;
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE accounts SET profilePicUrl = ? WHERE username = ?', [profilePicUrl, username]);
        res = true;
    });
    return res;
}

function deleteAccount(username) {
    var db = getDatabase();
    var res = false;
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM accounts WHERE username = ?', username);
        res = true;
    });
    return res;
}

function getAccount(username) {
    var db = getDatabase();
    var res = ""
    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT password FROM accounts WHERE username=?;', [username]);
            if (rs.rows.length > 0) {
              res = rs.rows.item(0).password;
            } else {
             res = "";
            }
        });
    } catch (err) {
        res = "";
    };
    return res
}

function getAccounts() {
    var db = getDatabase();
    var res = []
    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM accounts;');
            if (rs.rows.length > 0) {
              res = rs.rows;
            } else {
             res = [];
            }
        });
    } catch (err) {
        res = [];
    };
    return res
}



