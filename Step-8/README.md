This demo uses parse.com as a remote DB and EasyStore (https://github.com/sagarpshah/EasyStore) library.
It's using CocoaPods as well. Run "pod install" command after check-out.

1) Create Holiday from AddHolidayViewController.
2) When user will create a new Holiday, objectID  will be 'nil'. From objectID, we would identify whether created holiday is local or from server.
3) First of all, save the local holiday in DB, then save it on server and then update it with DB again with the objectID assigned from server.
4) Immediately after save, table will be refreshed. Other process would be running in background without user's awareness.
