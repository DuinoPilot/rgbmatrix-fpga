namespace GIF2RGBMatrix
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.ToolStripStatusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.VersionLabel = new System.Windows.Forms.Label();
            this.HostnameTextBox = new System.Windows.Forms.TextBox();
            this.StatusStrip1 = new System.Windows.Forms.StatusStrip();
            this.HostnameLabel = new System.Windows.Forms.Label();
            this.FilePathLabel = new System.Windows.Forms.Label();
            this.FilePathTextBox = new System.Windows.Forms.TextBox();
            this.BrowseButton = new System.Windows.Forms.Button();
            this.StartStopButton = new System.Windows.Forms.Button();
            this.PortNumberLabel = new System.Windows.Forms.Label();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.StatusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // ToolStripStatusLabel
            // 
            this.ToolStripStatusLabel.Name = "ToolStripStatusLabel";
            this.ToolStripStatusLabel.Size = new System.Drawing.Size(48, 17);
            this.ToolStripStatusLabel.Text = "Ready...";
            // 
            // VersionLabel
            // 
            this.VersionLabel.AutoSize = true;
            this.VersionLabel.Location = new System.Drawing.Point(344, 64);
            this.VersionLabel.Name = "VersionLabel";
            this.VersionLabel.Size = new System.Drawing.Size(60, 13);
            this.VersionLabel.TabIndex = 14;
            this.VersionLabel.Text = "Version 1.0";
            // 
            // HostnameTextBox
            // 
            this.HostnameTextBox.Location = new System.Drawing.Point(78, 33);
            this.HostnameTextBox.Name = "HostnameTextBox";
            this.HostnameTextBox.Size = new System.Drawing.Size(174, 20);
            this.HostnameTextBox.TabIndex = 11;
            this.HostnameTextBox.Text = "localhost";
            // 
            // StatusStrip1
            // 
            this.StatusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.ToolStripStatusLabel});
            this.StatusStrip1.Location = new System.Drawing.Point(0, 88);
            this.StatusStrip1.Name = "StatusStrip1";
            this.StatusStrip1.Size = new System.Drawing.Size(423, 22);
            this.StatusStrip1.SizingGrip = false;
            this.StatusStrip1.TabIndex = 13;
            this.StatusStrip1.Text = "StatusStrip";
            // 
            // HostnameLabel
            // 
            this.HostnameLabel.AutoSize = true;
            this.HostnameLabel.Location = new System.Drawing.Point(12, 36);
            this.HostnameLabel.Name = "HostnameLabel";
            this.HostnameLabel.Size = new System.Drawing.Size(55, 13);
            this.HostnameLabel.TabIndex = 16;
            this.HostnameLabel.Text = "Hostname";
            // 
            // FilePathLabel
            // 
            this.FilePathLabel.AutoSize = true;
            this.FilePathLabel.Location = new System.Drawing.Point(12, 9);
            this.FilePathLabel.Name = "FilePathLabel";
            this.FilePathLabel.Size = new System.Drawing.Size(60, 13);
            this.FilePathLabel.TabIndex = 15;
            this.FilePathLabel.Text = "Path to File";
            // 
            // FilePathTextBox
            // 
            this.FilePathTextBox.Location = new System.Drawing.Point(78, 6);
            this.FilePathTextBox.Name = "FilePathTextBox";
            this.FilePathTextBox.Size = new System.Drawing.Size(246, 20);
            this.FilePathTextBox.TabIndex = 9;
            // 
            // BrowseButton
            // 
            this.BrowseButton.Location = new System.Drawing.Point(330, 4);
            this.BrowseButton.Name = "BrowseButton";
            this.BrowseButton.Size = new System.Drawing.Size(75, 23);
            this.BrowseButton.TabIndex = 10;
            this.BrowseButton.Text = "&Browse...";
            this.BrowseButton.UseVisualStyleBackColor = true;
            this.BrowseButton.Click += new System.EventHandler(this.BrowseButton_Click);
            // 
            // StartStopButton
            // 
            this.StartStopButton.Location = new System.Drawing.Point(78, 59);
            this.StartStopButton.Name = "StartStopButton";
            this.StartStopButton.Size = new System.Drawing.Size(75, 23);
            this.StartStopButton.TabIndex = 13;
            this.StartStopButton.Text = "&Start / Stop";
            this.StartStopButton.UseVisualStyleBackColor = true;
            this.StartStopButton.Click += new System.EventHandler(this.StartStopButton_Click);
            // 
            // PortNumberLabel
            // 
            this.PortNumberLabel.AutoSize = true;
            this.PortNumberLabel.Location = new System.Drawing.Point(258, 36);
            this.PortNumberLabel.Name = "PortNumberLabel";
            this.PortNumberLabel.Size = new System.Drawing.Size(66, 13);
            this.PortNumberLabel.TabIndex = 17;
            this.PortNumberLabel.Text = "Port Number";
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(331, 33);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(74, 20);
            this.textBox1.TabIndex = 12;
            this.textBox1.Text = "5337";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(423, 110);
            this.Controls.Add(this.textBox1);
            this.Controls.Add(this.PortNumberLabel);
            this.Controls.Add(this.VersionLabel);
            this.Controls.Add(this.HostnameTextBox);
            this.Controls.Add(this.StatusStrip1);
            this.Controls.Add(this.HostnameLabel);
            this.Controls.Add(this.FilePathLabel);
            this.Controls.Add(this.FilePathTextBox);
            this.Controls.Add(this.BrowseButton);
            this.Controls.Add(this.StartStopButton);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "MainForm";
            this.Text = "Stream animated GIF to RGB LED Matrix JTAG server";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.StatusStrip1.ResumeLayout(false);
            this.StatusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        internal System.Windows.Forms.ToolStripStatusLabel ToolStripStatusLabel;
        internal System.Windows.Forms.Label VersionLabel;
        internal System.Windows.Forms.TextBox HostnameTextBox;
        internal System.Windows.Forms.StatusStrip StatusStrip1;
        internal System.Windows.Forms.Label HostnameLabel;
        internal System.Windows.Forms.Label FilePathLabel;
        internal System.Windows.Forms.TextBox FilePathTextBox;
        internal System.Windows.Forms.Button BrowseButton;
        internal System.Windows.Forms.Button StartStopButton;
        private System.Windows.Forms.Label PortNumberLabel;
        private System.Windows.Forms.TextBox textBox1;

    }
}

