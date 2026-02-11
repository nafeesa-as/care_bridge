// ignore: depend_on_referenced_packages
import 'package:firebase_data_connect/firebase_data_connect.dart';

class DefaultConnector {
  // Firebase Configuration
  static final ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1', // Firebase region
    'default', // Connector name
    'carebridge', // Project ID
  );

  late FirebaseDataConnect dataConnect;

  // Private constructor to ensure singleton pattern
  DefaultConnector._internal(this.dataConnect);

  // Singleton instance
  static DefaultConnector get instance {
    return DefaultConnector._internal(
      FirebaseDataConnect.instanceFor(connectorConfig: connectorConfig),
    );
  }
}
