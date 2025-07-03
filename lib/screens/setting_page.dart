import 'package:flutter/material.dart';
          import 'package:flutter_svg/flutter_svg.dart';

          class SettingsScreen extends StatelessWidget {
            final String jwtToken;
            const SettingsScreen({Key? key, required this.jwtToken}) : super(key: key);


            @override
            Widget build(BuildContext context) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Color(0xFF35746C)),
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 32),
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/img/settings.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF35746C),
                          ),
                        ),
                        const SizedBox(height: 70),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildSettingItem(
                                icon: Icons.person_outline,
                                title: 'Edit Profile',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.calendar_today_outlined,
                                title: 'Timetable & Calendar',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.phone_iphone_outlined,
                                title: 'Devices',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.color_lens_outlined,
                                title: 'Appearance',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.language_outlined,
                                title: 'Language',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.lock_outlined,
                                title: 'Privacy & Security',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.backup_outlined,
                                title: 'Backup & restore',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                icon: Icons.mail_outlined,
                                title: 'Contact Us',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/img/Ellipse_4.png',
                        // width: 60,
                        // height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Image.asset(
                        'assets/img/Ellipse_5.png',
                        // width: 60,
                        // height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),

                  ],
                ),
              );
            }

            static Widget _buildSettingItem({
              required IconData icon,
              required String title,
              required VoidCallback onTap,
            }) {
              return InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF35746C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFF35746C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }
          }