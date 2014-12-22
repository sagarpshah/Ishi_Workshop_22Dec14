This demo uses parse.com as a remote DB and EasyStore (https://github.com/sagarpshah/EasyStore) library.
It's using CocoaPods as well. Run "pod install" command after check-out.

1) In step-4, we inserted in DB same entry again and again with new KEY always.
2) We have to make sure NanoStore uses UPDATE query & not INSERT query, while adding (i.e. updating) objects with same objectID.