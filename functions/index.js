const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendPushNotification = functions.database.ref('/Messages/{id}').onWrite(event => {
    const message = event.data.val();    
    const token = message.fcmToken;

    if (!token) {
        return;
    } 
    const payload = {
        notification: {
            title: message.fromId,
            body:  message.text,
            badge: '1',
            sound: 'default'
        }
    };
    return admin.messaging().sendToDevice(token, payload).then(response => {

    });
});

