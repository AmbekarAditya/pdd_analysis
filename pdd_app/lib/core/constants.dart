import '../features/train_record/models/train_record.dart';

const Map<Department, List<String>> kDepartmentReasonMap = {
  Department.operating: [
    'Path unavailable', 
    'Crossing', 
    'Precedence', 
    'Platform unavailable',
    'Crew Movement Changed',
  ],
  Department.mechanical: [
    'Brake binding', 
    'Pipe disconnection', 
    'Hot axle', 
    'Spring breakage'
  ],
  Department.electrical: [
    'OHE snap', 
    'Pantograph broken', 
    'Loco failure', 
    'No tension'
  ],
  Department.snt: [
    'Signal failure', 
    'Point failure', 
    'Track circuit failure'
  ],
  Department.commercial: [
    'ACP', 
    'Loading/Unloading', 
    'Parcel loading'
  ],
  Department.security: [
    'Theft', 
    'Agitation', 
    'Line patrolling'
  ],
  Department.external: [
    'Fog', 
    'Flood', 
    'Public agitation', 
    'Cattle run over'
  ],
  Department.interDept: [
    'Late ordering', 
    'Crew shortage', 
    'Guard shortage',
    'Train Late Arrival',
  ],
};
