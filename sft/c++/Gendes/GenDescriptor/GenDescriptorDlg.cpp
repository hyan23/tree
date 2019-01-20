// GenDescriptorDlg.cpp
// Author: hyan23
// Date: 2016.06.02
//

#include "stdafx.h"
#include "GenDescriptor.h"
#include "GenDescriptorDlg.h"
#include "afxdialogex.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

CGenDescriptorDlg::CGenDescriptorDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CGenDescriptorDlg::IDD, pParent)
	, blG(FALSE)
	, blBD(TRUE)
	, blL(FALSE)
	, blAVL(FALSE)
	, blP(TRUE)
	, blTypeX(FALSE)
	, blTypeCE(FALSE)
	, blTypeRW(FALSE)
	, blTypeA(FALSE)
	, blPrivilege1(TRUE)
	, blPrivilege0(TRUE)
	, iRadio(0)
	, strBase(_T("00007c00"))
	, strLimit(_T("001ff"))
	, strText(_T("")) {
		m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CGenDescriptorDlg::DoDataExchange(CDataExchange* pDX) {
	CDialogEx::DoDataExchange(pDX);
	DDX_Check(pDX, IDC_CHECK_G, blG);
	DDX_Check(pDX, IDC_CHECK_DB, blBD);
	DDX_Check(pDX, IDC_CHECK_L, blL);
	DDX_Check(pDX, IDC_CHECK_AVL, blAVL);
	DDX_Check(pDX, IDC_CHECK_P, blP);
	DDX_Check(pDX, IDC_CHECK_TYPE_X, blTypeX);
	DDX_Check(pDX, IDC_CHECK_TYPE_CE, blTypeCE);
	DDX_Check(pDX, IDC_CHECK_TYPE_RW, blTypeRW);
	DDX_Check(pDX, IDC_CHECK_TYPE_A, blTypeA);
	DDX_Check(pDX, IDC_CHECK_PRIVILEGE1, blPrivilege1);
	DDX_Check(pDX, IDC_CHECK_PRIVILEGE0, blPrivilege0);
	DDV_MinMaxInt(pDX, iRadio, -1, 2);
	DDX_Text(pDX, IDC_EDIT_BASE, strBase);
	DDX_Text(pDX, IDC_EDIT_LIMIT, strLimit);
	DDX_Text(pDX, IDC_EDIT_OUT, strText);
	DDX_Radio(pDX, IDC_RADIO_CODE, iRadio);
}

BEGIN_MESSAGE_MAP(CGenDescriptorDlg, CDialogEx)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDOK, &CGenDescriptorDlg::OnBnClickedOk)
	ON_BN_CLICKED(IDC_BUTTON0, &CGenDescriptorDlg::OnBnClickedButton0)
END_MESSAGE_MAP()


// CGenDescriptorDlg消息处理程序
BOOL CGenDescriptorDlg::OnInitDialog(void) {
	CDialogEx::OnInitDialog();

	// 设置此对话框的图标。当应用程序主窗口不是对话框时，框架将自动
	//  执行此操作
	SetIcon(m_hIcon, TRUE);		// 设置大图标
	SetIcon(m_hIcon, FALSE);		// 设置小图标

	// TODO: 在此添加额外的初始化代码
	CDialogEx::UpdateData(FALSE);

	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

// 如果向对话框添加最小化按钮，则需要下面的代码
// 来绘制该图标。对于使用文档/视图模型的 MFC 应用程序，
// 这将由框架自动完成。

void CGenDescriptorDlg::OnPaint(void) {
	if (IsIconic()) {
		CPaintDC dc(this); // 用于绘制的设备上下文

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 使图标在工作区矩形中居中
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 绘制图标
		dc.DrawIcon(x, y, m_hIcon);
	} else {
		CDialogEx::OnPaint();
	}
}

//当用户拖动最小化窗口时系统调用此函数取得光标显示。
HCURSOR CGenDescriptorDlg::OnQueryDragIcon(void) {
	return static_cast<HCURSOR>(m_hIcon);
}

void CGenDescriptorDlg::OnBnClickedOk(void) {
	unsigned iBase = 0, iLimit = 0;
	char bufbase[1024 ] = { (char) 0 },
			buflimit[1024 ] = { (char) 0 };

	iLower = iUPPER = 0;

	CDialogEx::UpdateData(TRUE);
	if (8 != strBase.GetLength() || 5 != strLimit.GetLength()) {
		CDialogEx::MessageBox(_T("请输入正确的参数:\n段基址: 32位, 段界限: 20位。"),
			_T("错误"), MB_OK | MB_ICONERROR);
		return;
	}

	sprintf_s(bufbase, 1024, "%S", strBase);
	sprintf_s(buflimit, 1024, "%S", strLimit);

#pragma warning( push)
#pragma warning(disable:4996)
	if (0 == sscanf(bufbase, "%x", &iBase) ||
			0 == sscanf(buflimit, "%x", &iLimit)) {
		CDialogEx::MessageBox(_T("参数有误, 请检查。"),
			_T("错误"), MB_ICONERROR | MB_OK);
		return;
	}
#pragma warning( pop)

	iLower |= 0xffff & iLimit | (0xffff & iBase) << 16;
	iUPPER |= 0xff000000 & iBase | (0x00ff0000 & iBase) >> 16;
	iUPPER |= 0xf0000 & iLimit;

	if (blG) iUPPER |= 0x800000; // 23
	if (blBD) iUPPER |= 0x400000; // 22
	if (blL) iUPPER |= 0x200000; // 21
	if (blAVL) iUPPER |= 0x100000; // 20
	if (blP) iUPPER |= 0x8000; // 15
	if (blTypeX) iUPPER |= 0x800; // 11
	if (blTypeCE) iUPPER |= 0x400; // 10
	if (blTypeRW) iUPPER |= 0x200; // 9
	if (blTypeA) iUPPER |= 0x100; // 8
	if (blPrivilege1) iUPPER |= 0x4000; // 14
	if (blPrivilege0) iUPPER |= 0x2000; // 13
	if (2 != iRadio) iUPPER |= 0x1000; // 12

	strText.Format(_T("%08x_%08x"), iLower, iUPPER);
	CDialogEx::UpdateData(FALSE);
	// CDialogEx::OnOK();
}

void CGenDescriptorDlg::OnBnClickedButton0(void) {
	CDialogEx::MessageBox(_T("我不怎么需要这个功能, 所以还没有实现。"),
		_T("提示"), MB_OK | MB_ICONASTERISK);
	return;
}
