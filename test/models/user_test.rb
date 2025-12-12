# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
  end
  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '      '
    # refute is the same as assert_not
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '      '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    # Make a string using 'string multiplication'
    @user.name = "#{'a' * 244}@example.com"
    assert_not @user.valid?
  end

  test 'email should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password should be present (non-blank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should be able to follow and unfollow a user' do
    kermit = users(:kermit)
    lana = users(:lana)
    kermit.unfollow(lana)

    assert_not kermit.following?(lana)
    kermit.follow(lana)
    assert kermit.following?(lana)
    assert_includes lana.followers, kermit
    kermit.unfollow(lana)
    assert_not kermit.following?(lana)

    # Users can't follow themselves
    kermit.follow(kermit)
    assert_not kermit.following?(kermit)

    # Unfollow works even if user is not following
    assert_nothing_raised do
      kermit.unfollow(lana)
    end
  end

  test 'feed should have the right posts' do
    kermit = users(:kermit)
    gonzo = users(:gonzo)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert kermit.feed.include?(post_following)
    end
    # Self-posts for user with followers
    kermit.microposts.each do |post_self|
      assert kermit.feed.include?(post_self)
    end
    # Posts from a non-followed user
    gonzo.microposts.each do |post_unfollowed|
      assert_not kermit.feed.include?(post_unfollowed)
    end
  end
end
