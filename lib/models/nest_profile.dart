// lib/models/nest_profile.dart

enum Gender { male, female, other }

enum Relationship { lover, bestFriend, sibling, mentor }

class NestProfile {
  final Gender userGender;
  final Gender nestGender;
  final String personality;
  final Relationship relationship;

  NestProfile({
    this.userGender = Gender.other,
    this.nestGender = Gender.female,
    this.personality = "甘えん坊",
    this.relationship = Relationship.lover,
  });
}
