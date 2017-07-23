let functions = require('firebase-functions');
let admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendPushNotification = functions.database.ref('/Messages/{id}').onWrite(event => {
    let message = event.data.val();
    let toId = message.toId;
    let fromId = message.fromId;

    // Get fcmToken
    return admin.database().ref(`/Users/${toId}`).once('value').then(function (snapshot) {
        let fcmToken = snapshot.val().fcmToken;

        if (!fcmToken) {
            return;
        }

        // Get senderName
        admin.database().ref(`/Users/${fromId}`).once('value').then(function (snapshot) {
            let senderName = snapshot.val().name;

            // Fill pushMessage
            let payload = {
                notification: {
                    title: senderName,
                    body: message.text,
                    badge: '1',
                    sound: 'default'
                }
            };

            // Send push notification
            admin.messaging().sendToDevice(fcmToken, payload).then(response => {

            });

        });
    });
});

