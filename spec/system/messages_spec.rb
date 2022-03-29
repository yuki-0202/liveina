require 'rails_helper'

RSpec.describe 'チャット管理機能', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @booking = FactoryBot.create(:booking)
  end

  context 'チャット投稿テスト' do
    it 'チャットの投稿に成功すると、再びルーム詳細へ戻り、投稿した内容が表示されている' do
      sign_in(@user)
      visit booking_path(@booking.id)
      click_on('チャットルーム')
      expect(current_path).to eq(room_path(@booking.rooms.ids))
      fill_in 'message[content]', with: 'テスト'
      expect { click_on('送信') }.to change { Message.count }.by(1)
      expect(current_path).to eq(room_path(@booking.rooms.ids))
      expect(page).to have_content('テスト')
    end

    it '送る値が空の場合、チャットの投稿に失敗する' do
      sign_in(@user)
      visit booking_path(@booking.id)
      click_on('チャットルーム')
      expect(current_path).to eq(room_path(@booking.rooms.ids))
      fill_in 'message[content]', with: ''
      expect { click_on('送信') }.to change { Message.count }.by(0)
      expect(current_path).to eq(room_messages_path(@booking.rooms.ids))
      expect(page).to have_content('チャット履歴はありません')
    end

    it 'ブッキング投稿が削除されると、関連するルームとチャットが全て削除される' do
      @room_user = FactoryBot.create(:room_user)
      FactoryBot.create_list(:message, 5, room_id: @room_user.room.id, user_id: @room_user.user.id)
      sign_in(@room_user.room.booking.user)
      visit booking_path(@room_user.room.booking.id)
      click_on('削除')
      expect { click_on('削除する') }.to change { @room_user.room.messages.count }.by(-5)
      expect(current_path).to eq(root_path)
    end
  end
end
