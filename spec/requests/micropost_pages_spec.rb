require 'spec_helper'

describe "MicropostPages" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	before { sign_in user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid informaton" do

			it "should not create a micropost" do
				expect { click_button 'Post'}.not_to change(Micropost, :count)
			end
		end

		describe "error message" do
			before { click_button 'Post' }
			it{ should have_content('error') }
		end

		describe " with valid information" do
			before { fill_in 'micropost_content', with: 'Lorem ipsem' }
			it "should create a micopost" do
				expect { click_button 'Post' }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe "micropost destruction" do
		before { FactoryGirl.create(:micropost, user: user) }

		describe "as correct user" do
			before { visit root_path }

			it "should delete a micropost" do
				expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
			end
		end

		describe "view feed of another user" do
			let(:another_user) { FactoryGirl.create(:user) }
			before do
				FactoryGirl.create(:micropost, user: another_user)
				visit users_path
				click_link another_user.name
			end

			it { should_not have_selector('a', text: 'delete') }
		end
	end

	describe "micropost count" do
		before { visit root_path }

		it { should have_selector('span', text: user.microposts.count.to_s + ' micropost') }
	end

	describe "pagination" do

		before(:all) do
			
			30.times { FactoryGirl.create(:micropost, user: user) } 
			visit root_path
		end
		after(:all) { User.delete_all }

		
		# it { should have_selector('div.pagination') }

		Micropost.paginate(page: 1).each do |micropost|
			it { should have_selector('li', text: micropost.content)}
		end
	end
end
