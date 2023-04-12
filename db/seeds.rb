user = User.create(id: "defb5761-02b8-45ed-b660-8092a4c8d884", name: "Anna")
package_hp = Package.create(id: "5ee90d5a-d313-410d-a1b4-36d383b02ab6", track: "HP0001")
package_fd = Package.create(id: "1a133134-28ce-4dfa-8bca-7d84fdc5995e", track: "FD0001")

user.subscriptions.create(
  [
    { package: package_hp, email: "anna@mail.test", enabled: ["email"] },
    { package: package_fd, email: "anna@mail.test", phone: "+357 12349009", enabled: %w[phone email] }
  ]
)
