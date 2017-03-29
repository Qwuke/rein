require "spec_helper"
require "benchmark"

class RequireAuthorIsPresentOnBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :author, null: false
    end
    add_presence_constraint :books, :author
  end
end

class RequireIsbnIsPresentOnPublishedBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :status, null: false
      t.string :isbn
    end
    add_presence_constraint :books, :isbn, if: "status = 'published'"
  end
end

RSpec.describe Rein::Constraint::Presence do
  if !test_db_configuration("postgres")
    it "WARN: Skipping Postgres tests because no database found. Use spec/config/database.yml to configure one."

  else
    let!(:conn) { test_db_connection(test_db_configuration("postgres")) }

    before(:each) do
      migration.migrate(:up)
    end
    after(:each) do
      conn.execute "DROP TABLE IF EXISTS books"
    end

    context "always" do
      let(:migration) { RequireAuthorIsPresentOnBooks.new }

      it "should allow books with an author" do
        conn.execute "INSERT INTO books (author) VALUES ('Ernest Hemingway')"
        expect(conn.select_value("SELECT COUNT(*) FROM books").to_i).to eq 1
      end

      it "should forbid books with a blank author" do
        ["", "  ", "\t", "\n"].each do |author|
          expect {
            conn.execute "INSERT INTO books (author) VALUES ('#{author}')"
          }.to raise_error ActiveRecord::StatementInvalid
        end
      end
    end

    context "with if option" do
      let(:migration) { RequireIsbnIsPresentOnPublishedBooks.new }

      it "should allow books with an isbn" do
        conn.execute "INSERT INTO books (status, isbn) VALUES ('published', '0374528373')"
        expect(conn.select_value("SELECT COUNT(*) FROM books").to_i).to eq 1
      end

      it "should allow unpublished books with a blank isbn" do
        conn.execute "INSERT INTO books (status, isbn) VALUES ('unpublished', '')"
        expect(conn.select_value("SELECT COUNT(*) FROM books").to_i).to eq 1
      end

      it "should forbid published books with a blank isbn" do
        ["", "  ", "\t", "\n"].each do |isbn|
          expect {
            conn.execute "INSERT INTO books (status, isbn) VALUES ('published', '#{isbn}')"
          }.to raise_error ActiveRecord::StatementInvalid
        end
      end
    end
  end
end
