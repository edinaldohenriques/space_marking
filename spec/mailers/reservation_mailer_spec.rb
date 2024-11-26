require "rails_helper"

RSpec.describe ReservationMailer, type: :mailer do
  describe "notify_admin_new_reservation" do
    let(:mail) { ReservationMailer.notify_admin_new_reservation }

    it "renders the headers" do
      expect(mail.subject).to eq("Notify admin new reservation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
