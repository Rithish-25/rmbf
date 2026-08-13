class Member {
  final String name;
  final String businessName;
  final String chapter;
  final String location;
  final String phone;
  final String bloodGroup;
  final String nativeAddress;
  final String email;
  final String fatherName;
  final String spouseName;
  final String education;
  final String? profileImage;
  final bool isPro;
  final String kootam;
  final String dob;
  final String weddingDay;
  final String companyOpenDay;
  final String officeAddress;
  final String powerMeetingName;
  final String position;

  Member({
    required this.name,
    required this.businessName,
    required this.chapter,
    required this.location,
    required this.phone,
    required this.bloodGroup,
    required this.nativeAddress,
    required this.email,
    required this.fatherName,
    required this.spouseName,
    required this.education,
    this.profileImage,
    required this.isPro,
    required this.kootam,
    this.dob = "",
    this.weddingDay = "",
    this.companyOpenDay = "",
    this.officeAddress = "",
    this.powerMeetingName = "UNITY Power Meeting",
    this.position = "Member",
  });

  Member copyWith({
    String? name,
    String? businessName,
    String? chapter,
    String? location,
    String? phone,
    String? bloodGroup,
    String? nativeAddress,
    String? email,
    String? fatherName,
    String? spouseName,
    String? education,
    String? profileImage,
    bool? isPro,
    String? kootam,
    String? dob,
    String? weddingDay,
    String? companyOpenDay,
    String? officeAddress,
    String? powerMeetingName,
    String? position,
  }) {
    return Member(
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      chapter: chapter ?? this.chapter,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      nativeAddress: nativeAddress ?? this.nativeAddress,
      email: email ?? this.email,
      fatherName: fatherName ?? this.fatherName,
      spouseName: spouseName ?? this.spouseName,
      education: education ?? this.education,
      profileImage: profileImage ?? this.profileImage,
      isPro: isPro ?? this.isPro,
      kootam: kootam ?? this.kootam,
      dob: dob ?? this.dob,
      weddingDay: weddingDay ?? this.weddingDay,
      companyOpenDay: companyOpenDay ?? this.companyOpenDay,
      officeAddress: officeAddress ?? this.officeAddress,
      powerMeetingName: powerMeetingName ?? this.powerMeetingName,
      position: position ?? this.position,
    );
  }
}

class Meeting {
  final String title;
  final String date;
  final String type; // "KG-Meet" or "Other Meet"
  final bool attended;

  Meeting({
    required this.title,
    required this.date,
    required this.type,
    required this.attended,
  });
}

class ThanksNote {
  final String id;
  final String memberName;
  final String businessName;
  final double amount;
  final bool isReferral;
  final bool isGiven; // true if Given, false if Taken
  final String date;
  final String? attachmentName;
  final String? referralType; // "Self" or "Other"
  final String? referralPhone; // Phone number

  ThanksNote({
    required this.id,
    required this.memberName,
    required this.businessName,
    required this.amount,
    required this.isReferral,
    required this.isGiven,
    required this.date,
    this.attachmentName,
    this.referralType,
    this.referralPhone,
  });
}

class MockData {
  static Member currentUser = Member(
    name: "Santhosh M.R.",
    businessName: "ZION Constructions and Interiors",
    chapter: "UNITY Team",
    location: "Settaikara Chettangal",
    phone: "9865486727",
    bloodGroup: "B+",
    nativeAddress: "150 Points",
    email: "santhosh.zion@gmail.com",
    fatherName: "Ramasamy M.",
    spouseName: "Priyanka S.",
    education: "B.E. Civil Engineering",
    profileImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&fit=crop&q=80",
    isPro: true,
    kootam: "Unity",
    dob: "1988-06-15",
    weddingDay: "2013-11-20",
    companyOpenDay: "2018-03-10",
    officeAddress: "45, Perundurai Road, Erode - 638011",
    powerMeetingName: "UNITY Power Meeting",
    position: "President",
  );

  static final List<Member> members = [
    Member(
      name: "A Suresh Kumar",
      businessName: "The Event Today",
      chapter: "UNITY Team",
      location: "Salem Main Road",
      phone: "8508003335",
      bloodGroup: "A+",
      nativeAddress: "95 Points",
      email: "suresh.events@yahoo.com",
      fatherName: "Arumugam K.",
      spouseName: "Deepa S.",
      education: "MBA Marketing",
      profileImage: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&fit=crop&q=80",
      isPro: false,
      kootam: "N/A",
      dob: "1986-04-12",
      weddingDay: "2012-05-18",
      companyOpenDay: "2015-09-01",
      officeAddress: "Salem Main Road, Erode",
    ),
    Member(
      name: "A. Muthukumar",
      businessName: "Srivari Digital Land Surveying (DGPS)",
      chapter: "UNITY Team",
      location: "Perundurai",
      phone: "9944221155",
      bloodGroup: "A-",
      nativeAddress: "120 Points",
      email: "muthu.survey@gmail.com",
      fatherName: "Angamuthu P.",
      spouseName: "Chitra M.",
      education: "Diploma in Civil",
      profileImage: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&fit=crop&q=80",
      isPro: true,
      kootam: "Unity",
      dob: "1990-12-05",
      weddingDay: "2017-02-14",
      companyOpenDay: "2019-06-20",
      officeAddress: "Perundurai, Erode",
    ),
    Member(
      name: "A. Kaleeswaran",
      businessName: "Rajalakshmi Textile",
      chapter: "UNITY Team",
      location: "Tiruppur",
      phone: "9843012345",
      bloodGroup: "B+",
      nativeAddress: "210 Points",
      email: "kaleeswaran.tex@gmail.com",
      fatherName: "Arunachalam K.",
      spouseName: "Kokila K.",
      education: "B.Tech Fashion Tech",
      profileImage: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&fit=crop&q=80",
      isPro: true,
      kootam: "Unity",
      dob: "1984-07-22",
      weddingDay: "2010-09-15",
      companyOpenDay: "2012-11-05",
      officeAddress: "Tiruppur",
    ),
    Member(
      name: "Aarthi G P",
      businessName: "Saagitya Food Products",
      chapter: "UNITY Team",
      location: "Coimbatore",
      phone: "9080706050",
      bloodGroup: "B-",
      nativeAddress: "80 Points",
      email: "aarthi.foods@outlook.com",
      fatherName: "Palanisamy G.",
      spouseName: "Gopal R.",
      education: "M.Sc Food Science",
      profileImage: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&fit=crop&q=80",
      isPro: false,
      kootam: "N/A",
      dob: "1993-09-18",
      weddingDay: "2020-01-25",
      companyOpenDay: "2021-08-10",
      officeAddress: "Coimbatore",
    ),
    Member(
      name: "A. Loganathan",
      businessName: "Apex Solar Systems",
      chapter: "UNITY Team",
      location: "Bhavani",
      phone: "9443311223",
      bloodGroup: "O+",
      nativeAddress: "130 Points",
      email: "logu.solar@gmail.com",
      fatherName: "Loganathan S.",
      spouseName: "Kavitha L.",
      education: "B.E. Electrical",
      profileImage: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&fit=crop&q=80",
      isPro: true,
      kootam: "Unity",
      dob: "1985-03-30",
      weddingDay: "2011-06-22",
      companyOpenDay: "2014-04-15",
      officeAddress: "Bhavani, Erode",
    ),
  ];

  static final List<Meeting> meetings = [
    Meeting(title: "INTERCHAPTERMEET", date: "2026-08-08", type: "KG-Meet", attended: true),
    Meeting(title: "6TH KGMEET GOBI", date: "2026-08-01", type: "KG-Meet", attended: true),
    Meeting(title: "5TH KGMEET GOBI", date: "2026-07-25", type: "KG-Meet", attended: false),
    Meeting(title: "ANNUAL NETWORKING GALA", date: "2026-07-15", type: "Other Meet", attended: true),
    Meeting(title: "BUSINESS SUMMIT 2026", date: "2026-07-10", type: "Other Meet", attended: true),
    Meeting(title: "4TH KGMEET GOBI", date: "2026-07-04", type: "KG-Meet", attended: false),
    Meeting(title: "3RD KGMEET GOBI", date: "2026-06-27", type: "KG-Meet", attended: true),
  ];

  static final List<ThanksNote> thanksNotes = [
    ThanksNote(
      id: "TXN101",
      memberName: "A Suresh Kumar",
      businessName: "The Event Today",
      amount: 150000,
      isReferral: true,
      isGiven: true,
      date: "2026-08-09",
      referralType: "Other",
      referralPhone: "8508003335",
    ),
    ThanksNote(
      id: "TXN102",
      memberName: "A. Muthukumar",
      businessName: "Srivari Digital Land Surveying",
      amount: 653604,
      isReferral: true,
      isGiven: true,
      date: "2026-08-05",
      referralType: "Other",
      referralPhone: "9944221155",
    ),
    ThanksNote(
      id: "TXN103",
      memberName: "A. Kaleeswaran",
      businessName: "Rajalakshmi Textile",
      amount: 1250000,
      isReferral: false,
      isGiven: false,
      date: "2026-08-04",
    ),
    ThanksNote(
      id: "TXN104",
      memberName: "Aarthi G P",
      businessName: "Saagitya Food Products",
      amount: 625872,
      isReferral: false,
      isGiven: false,
      date: "2026-07-28",
    ),
  ];

  static final List<RtoREntry> rtoRHistories = [
    RtoREntry(
      userName: "Santhosh M.R.",
      partnerName: "A Suresh Kumar",
      date: "2026-08-10",
    ),
    RtoREntry(
      userName: "Santhosh M.R.",
      partnerName: "A. Muthukumar",
      date: "2026-08-08",
    ),
    RtoREntry(
      userName: "Santhosh M.R.",
      partnerName: "A. Kaleeswaran",
      date: "2026-08-04",
    ),
  ];
}

class RtoREntry {
  final String userName;
  final String partnerName;
  final String date;

  RtoREntry({
    required this.userName,
    required this.partnerName,
    required this.date,
  });
}

class Booking {
  final String id;
  final String title;
  final String type;
  final String date;
  final String colorCode;
  final String description;
  final String time;

  Booking({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.colorCode,
    required this.description,
    required this.time,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      colorCode: json['colorCode'] ?? json['color'] ?? '#1E3A8A',
      description: json['description'] ?? '',
      time: json['time'] ?? 'All Day',
    );
  }
}

class NewsEvent {
  final String id;
  final String title;
  final String date;
  final String imageUrl;
  final String description;
  final String location;

  NewsEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.description,
    required this.location,
  });

  factory NewsEvent.fromJson(Map<String, dynamic> json) {
    return NewsEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
