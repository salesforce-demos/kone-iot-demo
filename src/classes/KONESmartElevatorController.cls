public with sharing class KONESmartElevatorController {

    private static final Integer ELEVATOR_INSTANCES = 5;

    public String publishStatus { get; set; }
    private Elevator[] elevators;


    public KONESmartElevatorController() {

        elevators = new Elevator[]{};

        for (Integer i = 1; i <= ELEVATOR_INSTANCES; i++) {
            Elevator elevator = new Elevator();
            elevator.id = i;
            elevators.add(elevator);
        }
    }


    public void resetToStart() {

        for (Elevator elevator : elevators) {
            elevator.status = 0;
        }

        pushEvents(elevators);
    }


    public void initiateWATSONEvent() {

        Elevator watsonElevator;

        for (Elevator elevator : elevators) {

            if (elevator.status != 99) {
                elevator.status = 99;
                watsonElevator = elevator;
                break;
            }
        }

        if (watsonElevator != null) {
            pushEvents(new Elevator[]{ watsonElevator });
        }
    }


    private void pushEvents(Elevator[] elevators) {

        Kone_Event__e[] events = new Kone_Event__e[]{};

        for (Elevator elevator : elevators) {
            Kone_Event__e event = new Kone_Event__e();
            event.Id__c = elevator.id;
            event.Status__c = elevator.status;
            events.add(event);
        }

        publishStatus = null;

        for (Database.SaveResult sr : EventBus.publish(events)) {

            if (sr.isSuccess()) {
                publishStatus = 'SUCCESS';
                System.debug('Successfully published event.');
            }
            else {
                publishStatus = 'ERROR';
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +  err.getStatusCode() +  ' - ' +  err.getMessage());
                }
            }
        }
    }


    private class Elevator {
        public Integer id;
        public Integer status;
    }
}