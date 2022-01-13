class BTClient_QuickStartSound Extends CriticalEventPlus;

var name CountDownSound[5];

Static Function ClientReceive
    (
        PlayerController P,
        optional int Switch,
        optional PlayerReplicationInfo RelatedPRI_1,
        optional PlayerReplicationInfo RelatedPRI_2,
        optional Object OptionalObject
    )
{
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	if (Switch > 0 && Switch <= 5 && P != None)
		P.QueueAnnouncement(Default.CountDownSound[Switch-1], 1, AP_InstantOrQueueSwitch, 1);
}

defaultproperties
{
     CountDownSound(0)="one"
     CountDownSound(1)="two"
     CountDownSound(2)="three"
     CountDownSound(3)="four"
     CountDownSound(4)="five"
}
