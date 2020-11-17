#-- encoding: UTF-8
#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2020 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe OpenProject::TextFormatting::Formats::Markdown::Formatter do
  it 'should modifiers' do
    assert_html_output(
      '**bold**'                => '<strong>bold</strong>',
      'before **bold**'         => 'before <strong>bold</strong>',
      '**bold** after'          => '<strong>bold</strong> after',
      '**two words**'           => '<strong>two words</strong>',
      '**two*words**'           => '<strong>two*words</strong>',
      '**two * words**'         => '<strong>two * words</strong>',
      '**two** **words**'         => '<strong>two</strong> <strong>words</strong>',
      '**(two)** **(words)**'     => '<strong>(two)</strong> <strong>(words)</strong>'
    )
  end

  it 'escapes script tags' do
    assert_html_output(
      'this is a <script>' => 'this is a &lt;script&gt;'
    )
  end

  it 'limits `a` tags and hardens them against tabnabbing' do
    assert_html_output(
      'this is a <a style="display:none;" href="http://malicious">' =>
        'this is a <a href="http://malicious" rel="noopener noreferrer">'
    )
  end

  it 'should double dashes should not strikethrough' do
    assert_html_output(
      'double -- dashes -- test' => 'double -- dashes -- test',
      'double -- **dashes** -- test' => 'double -- <strong>dashes</strong> -- test'
    )
  end

  it 'should inline auto link' do
    assert_html_output(
      'Autolink to http://www.google.com' => 'Autolink to <a class="rinku-autolink" href="http://www.google.com">http://www.google.com</a>'
    )
  end

  it 'should inline auto link email addresses' do
    assert_html_output(
      'Mailto link to foo@bar.com' => 'Mailto link to <a class="rinku-autolink" href="mailto:foo@bar.com">foo@bar.com</a>'
    )
  end

  describe 'mail address autolink' do
    it 'prints autolinks for user references not existing' do
      assert_html_output(
        'Link to user:"foo@bar.com"' => 'Link to user:"<a href="mailto:foo@bar.com" class="rinku-autolink">foo@bar.com</a>"'
      )
    end

    context 'when visible user exists' do
      shared_let(:project) { FactoryBot.create :project }
      shared_let(:role) { FactoryBot.create(:role, permissions: %i(view_work_packages)) }
      shared_let(:current_user) do
        FactoryBot.create(:user,
                          member_in_project: project,
                          member_through_role: role)
      end
      shared_let(:user) do
        FactoryBot.create(:user,
                          login: 'foo@bar.com',
                          firstname: 'Foo',
                          lastname: 'Barrit',
                          member_in_project: project,
                          member_through_role: role)
      end

      before do
        user
        login_as current_user
      end

      context 'with path only' do
        it 'outputs the reference' do
          assert_html_output(
            'Link to user:"foo@bar.com"' => %(Link to <a class="user-mention" href="/users/#{user.id}" title="User Foo Barrit">Foo Barrit</a>)
          )
        end

        it 'does not replace all relative hrefs and images' do
          assert_html_output(
            {
              'Link to [relative path](/foo/bar)' =>
                %(Link to <a href="/foo/bar" rel="noopener noreferrer">relative path</a>),
              'An inline image ![](/attachments/123/foobar.png)' =>
                %(An inline image <img src="/attachments/123/foobar.png" alt="" />)
            },
            only_path: true
          )
        end
      end

      context 'with relative URLs (path_only is false)', with_settings: { host_name: "openproject.org" } do
        it 'outputs the reference' do
          assert_html_output(
            {
              'Link to user:"foo@bar.com"' =>
                %(Link to <a class="user-mention" href="http://openproject.org/users/#{user.id}" title="User Foo Barrit">Foo Barrit</a>)
            },
            only_path: false
          )
        end

        it 'replaces all relative hrefs and images' do
          assert_html_output(
            {
              'Link to [relative path](/foo/bar)' =>
                %(Link to <a href="http://openproject.org/foo/bar" rel="noopener noreferrer">relative path</a>),
              'An inline image ![](/attachments/123/foobar.png)' =>
                %(An inline image <img src="http://openproject.org/attachments/123/foobar.png" alt="" />)
            },
            only_path: false
          )
        end
      end
    end
  end

  it 'should table' do
    raw = <<-RAW.strip_heredoc
      This is a table with header cells:

      |header|header|
      |------|------|
      |cell11|cell12|
      |cell21|cell23|
      |cell31|cell32|
    RAW

    expected = <<-EXPECTED.strip_heredoc
      <p class="op-uc-p">This is a table with header cells:</p>

      <table>
        <thead>
          <tr><th>header</th><th>header</th></tr>
        </thead>
        <tbody>
        <tr><td>cell11</td><td>cell12</td></tr>
        <tr><td>cell21</td><td>cell23</td></tr>
        <tr><td>cell31</td><td>cell32</td></tr>
        </tbody>
      </table>
    EXPECTED

    expect(to_html(raw).gsub(%r{\s+}, '')).to eq(expected.gsub(%r{\s+}, ''))
  end

  it 'should not mangle brackets' do
    expect(to_html('[msg1][msg2]')).to eq '<p class="op-uc-p">[msg1][msg2]</p>'
  end

  it 'should textile should escape image urls' do
    # this is onclick="alert('XSS');" in encoded form
    raw = '![](/images/comment.png"onclick=&#x61;&#x6c;&#x65;&#x72;&#x74;&#x28;&#x27;&#x58;&#x53;&#x53;&#x27;&#x29;;&#x22;)'
    expected = %[<p class="op-uc-p"><imgsrc="/images/comment.png%22onclick=alert('XSS');%22" alt=""></p>]

    expect(expected.gsub(%r{\s+}, '')).to eq(to_html(raw).gsub(%r{\s+}, ''))
  end

  private

  def assert_html_output(to_test, options = {})
    options = { expect_paragraph: true }.merge options
    expect_paragraph = options.delete :expect_paragraph

    to_test.each do |text, expected|
      expected = expect_paragraph ? "<p class=\"op-uc-p\">#{expected}</p>" : expected
      expect(to_html(text, options)).to be_html_eql expected
    end
  end

  def to_html(text, options = {})
    described_class.new(options).to_html(text)
  end
end
